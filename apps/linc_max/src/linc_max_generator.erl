-module(linc_max_generator).
-export([update_flow_table/2]).

-define(ETH_P_IP,			16#0800).
-define(ETH_P_ARP,			16#0806).
-define(ETH_P_IPV6,			16#86dd).

-define(VLAN_VID_NONE,		16#0000).
-define(VLAN_VID_PRESENT,	16#1000).

update_flow_table(TabName, FlowEnts) ->
	EntsWithVersions = versions(FlowEnts),

	F1 = {attribute,0,module,TabName},
	F2 = {attribute,0,export,
			[{FName,length(Args)}
				|| {FName,Args} <- function_signatures()]},
	Fs = [{function,0,FName,length(Args),
						clauses(EntsWithVersions, Args)}
				|| {FName,Args} <- function_signatures()],

	Forms = [F1,F2|Fs],
%	lists:foreach(fun(F) ->
%		io:format("~s", [erl_pp:form(F)])
%	end, Forms),

	{ok,TabName,Bin} = compile:forms(Forms, []),

	case erlang:check_old_code(TabName) of
	true ->
		erlang:purge_module(TabName);
	_ ->
		ok
	end,
	{module,_} = erlang:load_module(TabName, Bin),
	ok.

%% duplicate clauses that depend on IPv4/IPv6
versions(Ents) ->
	versions(Ents, []).

versions([], Acc) ->
	lists:reverse(Acc);
versions([{Action,Matches}|Ents], Acc) ->
	case lists:keymember(ip_proto, 1, Matches) orelse
		 lists:keymember(ip_dscp, 1, Matches) orelse
		 lists:keymember(ip_ecn, 1, Matches) of
	true ->
		versions(Ents, [{Action,Matches,v4},
						{Action,Matches,v6}|Acc]);
	false ->
		versions(Ents, [{Action,Matches,any}|Acc])
	end.

clauses(Ents, Args) ->
	clauses(Ents, Args, []).

clauses([], _, Acc) ->
	lists:reverse(Acc);
clauses([{Action,Matches,Version}|Ents], Args, Acc) ->
	Specs = [spec(M, Version) || M <- Matches]
				++
			 match_version(Version),
	RefArgs = lists:usort([A || {A,_} <- Specs]),
	case RefArgs -- Args of
	[] ->
		ArgZones = [
			{Arg,
		 		begin
					Ys = lists:concat([Xs
							|| {Arg1,Xs} <- Specs,Arg1 =:= Arg]),
					combine(lists:keysort(1, Ys))
				end}
					|| Arg <- RefArgs],
		Ps = lists:map(fun(A) ->
			case lists:keyfind(A, 1, ArgZones) of
			false ->
				{var,0,'_'};
			{_,[Value]} when is_integer(Value) ->
				{integer,0,Value};
			{_,[none]} ->
				{atom,0,none};
			{_,Zs} ->
				{bin,0,bin_elems(Zs)}
			end
		end, Args),
		C = {clause,0,Ps,[],[{atom,0,Action}]},
		clauses(Ents, Args, [C|Acc]);
	_Xs ->
		%io:format("no chance: Xs = ~p\n", [Xs]),
		%% no chance of a match
		clauses(Ents, Args, Acc)
	end.

match_version(v4) ->
	[{eth_type,[?ETH_P_IP]}];
match_version(v6) ->
	[{eth_type,[?ETH_P_IPV6]}];
match_version(_) ->
	[].

combine(Ts) ->
	combine(Ts, []).

combine([T], Acc) ->
	lists:reverse([T|Acc]);
combine([nomatch|_], _Acc) ->
	nomatch;
combine([Val,[Val|_] =Ts], Acc) when is_integer(Val) ->
	combine(Ts, Acc);
combine([Val1,[Val2|_]], _Acc) when is_integer(Val1), is_integer(Val2) ->
	nomatch;
combine([{Start1,Len1,_Val1} =T|[{Start2,_Len2,_Val2}|_] =Ts], Acc)
		when Start1 +Len1 < Start2 ->
	combine(Ts, [T|Acc]);
combine([T1,T2|Ts], Acc) ->
	%io:format("combine ~p and ~p~n", [T1,T2]),
	combine([combine1(T1, T2)|Ts], Acc).

combine1({S1,L1,V1} =T1, {S2,L2,_V2} =T2) ->
	IS = S2,
	X = S1 +L1 -S2,
	IL = if X < L2 -> X; true -> L2 end,
	IV1 = cut(T1, IS, IL),
	IV2 = cut(T2, IS, IL),
	TS = S1 +L1,
	TL = S2 +L2 -TS,
	if IV1 =/= IV2 ->
		io:format("nomatch: ~p =/= ~p~n", [T1,T2]),
		nomatch;
	TL =< 0 ->
		T1;
	true ->
		{S1,
		 L1 +TL,
		 (V1 bsl TL) bor cut(T2, TS, TL)}
	end.

cut({S,L,V}, SA, LA) ->
	X = S +L -SA -LA,
	(V bsr X) band ((1 bsl LA) -1).

bin_elems(Zs) ->
	bin_elems(0, Zs, []).

bin_elems(O, [], Acc) when O rem 8 =:= 0 ->
	E = {bin_element,0,{var,0,'_'},default,[binary]},
	lists:reverse([E|Acc]);
bin_elems(_O, [], Acc) ->
	E = {bin_element,0,{var,0,'_'},default,[bits]},
	lists:reverse([E|Acc]);
bin_elems(O, [{S,_,_}|_] =Zs, Acc) when S > O ->
	E = {bin_element,0,{var,0,'_'},{integer,0,S -O},[bits]},
	bin_elems(S, Zs, [E|Acc]);
bin_elems(S, [{S,0,0}|Zs], Acc) ->
	bin_elems(S, Zs, Acc);
bin_elems(S, [{S,L,V}|Zs], Acc) when L >= 8 ->
	S1 = S +8,
	L1 = L -8,
	V0 = V bsr L1,
	V1 = V band ((1 bsl L1) -1),
	E = {bin_element,0,{integer,0,V0},default,default},
	bin_elems(S1, [{S1,L1,V1}|Zs], [E|Acc]);
bin_elems(S, [{S,L,V}|Zs], Acc) ->
	E = {bin_element,0,{integer,0,V},{integer,0,L},default},
	bin_elems(S +L, Zs, [E|Acc]).

spec({in_port,Value}, _) ->
	{in_port,[Value]};
spec({in_phy_port,Value}, _) ->
	{in_phy_port,[Value]};
spec({metadata,Value,Mask}, _) ->
	masq(metadata, 0, 64, Value, Mask);
spec({eth_dst,Value,Mask}, _) ->
	masq(packet, 0, 48, Value, Mask);
spec({eth_src,Value,Mask}, _) ->
	masq(packet, 48, 48, Value, Mask);
spec({eth_type,Value}, _) ->
	{eth_type,[Value]};
spec({vlan_vid,?VLAN_VID_NONE,nomask}, _) ->
	{vlan_vid,[none]};
spec({vlan_vid,?VLAN_VID_PRESENT,?VLAN_VID_PRESENT}, _) ->
	{vlan_vid,[{0,0,0}]};
spec({vlan_vid,Value,nomask}, _) ->
	masq(vlan_tag, 4, 12, Value, nomask);
spec({vlan_pcp,Value}, _) ->
	masq(vlan_tag, 0, 3, Value, nomask);
spec({ip_dscp,Value}, v4) ->
	masq(ip4_hdr, 8, 6, Value, nomask);
spec({ip_dscp,Value}, v6) ->
	masq(ip6_hdr, 4, 6, Value, nomask);
spec({ip_ecn,Value}, v4) ->
	masq(ip4_hdr, 14, 2, Value, nomask);
spec({ip_ecn,Value}, v6) ->
	masq(ip6_hdr, 10, 2, Value, nomask);
spec({ip_proto,Value}, v4) ->
	masq(ip4_hdr, 72, 8, Value, nomask);
spec({ip_proto,Value}, v6) ->
	%%TODO: this is the first header, not the last
	masq(ip6_hdr, 48, 8, Value, nomask);
spec({ipv4_src,Value,Mask}, _) ->
	masq(ip4_hdr, 96, 32, Value, Mask);
spec({ipv4_dst,Value,Mask}, _) ->
	masq(ip4_hdr, 128, 32, Value, Mask);
spec({tcp_src,Value}, _) ->
	masq(tcp_hdr, 0, 16, Value, nomask);
spec({tcp_dst,Value}, _) ->
	masq(tcp_hdr, 16, 16, Value, nomask);
spec({udp_src,Value}, _) ->
	masq(udp_hdr, 0, 16, Value, nomask);
spec({udp_dst,Value}, _) ->
	masq(udp_hdr, 16, 16, Value, nomask);
spec({sctp_src,Value}, _) ->
	masq(sctp_hdr, 0, 16, Value, nomask);
spec({sctp_dst,Value}, _) ->
	masq(sctp_hdr, 16, 16, Value, nomask);
spec({icmpv4_type,Value}, _) ->
	masq(icmp_hdr, 0, 8, Value, nomask);
spec({icmpv4_code,Value}, _) ->
	masq(icmp_msg, 8, 8, Value, nomask);
spec({arp_op,Value}, _) ->
	masq(arp_msg, 48, 16, Value, nomask);
spec({arp_spa,Value,Mask}, _) ->
	masq(arp_msg, 112, 32, Value, Mask);
spec({arp_tpa,Value,Mask}, _) ->
	masq(arp_msg, 192, 32, Value, Mask);
spec({arp_sha,Value,Mask}, _) ->
	masq(arp_msg, 48, 48, Value, Mask);
spec({arp_tha,Value,Mask}, _) ->
	masq(arp_msg, 144, 48, Value, Mask);
spec({ipv6_src,Value,Mask}, _) ->
	masq(ip6_hdr, 64, 128, Value, Mask);
spec({ipv6_dst,Value,Mask}, _) ->
	masq(ip6_hdr, 192, 128, Value, Mask);
spec({ipv6_flabel,Value,Mask}, _) ->
	masq(ip6_hdr, 12, 20, Value, Mask);
spec({icmpv6_type,Value}, _) ->
	masq(icmp6_hdr, 0, 8, Value, nomask);
spec({icmpv6_code,Value}, _) ->
	masq(icmp6_hdr, 8, 8, Value, nomask);
spec({ipv6_nd_target,_Value}, _) ->
	todo; %%TODO use guard that nd_sll or nd_tll is not 'none'
spec({ipv6_nd_sll,Value}, _) ->
	{ip6_sll,[Value]};
spec({ipv6_nd_tll,Value}, _) ->
	{ip6_tll,[Value]};
spec({mpls_label,Value}, _) ->
	masq(mpls_tag, 0, 20, Value, nomask);
spec({mpls_tc,Value}, _) ->
	masq(mpls_tag, 20, 3, Value, nomask);
spec({mpls_bos,Value}, _) ->
	masq(mpls_tag, 23, 1, Value, nomask);
spec({pbb_isid,Value,Mask}, _) ->
	masq(pbb_tag, 8, 24, Value, Mask);
spec({tunnel_id,Value,Mask}, _) ->
	masq(tunnel_id, 0, 64, Value, Mask);
spec({ipv6_exthdr,Value,Mask}, _) ->
	masq(ip6_ext, 0, 9, Value, Mask);
spec({pbb_uca,Value}, _) ->
	masq(pbb_tag, 4, 1, Value, nomask).

masq(Arg, Start, Bits, Value, nomask) ->
	{Arg,[{Start,Bits,Value}]};
masq(Arg, Start, Bits, Value, Mask) ->
	{Arg,[{Start +Bits -Pos -Len,
		   Len,
		   (Value band sub_mask(Pos, Len)) bsr Pos}
				|| {Pos,Len} <- split_mask(Mask)]}.

split_mask(Mask) ->
	split_mask(Mask, 0, 1, 0, []).

split_mask(0, _, _, 0, Acc) ->
	Acc;
split_mask(0, N, _, Ones, Acc) ->
	[{N -Ones,Ones}|Acc];
split_mask(Mask, N, Probe, Ones, Acc) when Mask band Probe =/= 0 ->
	split_mask(Mask band (bnot Probe), N +1, Probe bsl 1, Ones +1, Acc);
split_mask(Mask, N, Probe, 0, Acc) ->
	split_mask(Mask, N +1, Probe bsl 1, 0, Acc);
split_mask(Mask, N, Probe, Ones, Acc) ->
	split_mask(Mask, N +1, Probe bsl 1, 0, [{N -Ones,Ones}|Acc]).

sub_mask(N, L) ->
	((1 bsl L) -1) bsl N.

function_signatures() ->
	[{arp,
		[packet,
		 vlan_tag,
		 eth_type,
		 pbb_tag,
		 mpls_tag,
		 ip4_hdr,
		 ip6_hdr,
		 ip6_ext,
		 arp_msg,
		 in_port,
		 in_phy_port,
		 metadata,
		 tunnel_id]},
	 {icmp,
		[packet,
		 vlan_tag,
		 eth_type,
		 pbb_tag,
		 mpls_tag,
		 ip4_hdr,
		 ip6_hdr,
		 ip6_ext,
		 icmp_msg,
		 in_port,
		 in_phy_port,
		 metadata,
		 tunnel_id]},
	 {icmpv6,
		[packet,
		 vlan_tag,
		 eth_type,
		 pbb_tag,
		 mpls_tag,
		 ip4_hdr,
		 ip6_hdr,
		 ip6_ext,
		 icmp6_hdr,
		 icmp6_sll,
		 icmp6_tll,
		 in_port,
		 in_phy_port,
		 metadata,
		 tunnel_id]},
	 {tcp,
		[packet,
		 vlan_tag,
		 eth_type,
		 pbb_tag,
		 mpls_tag,
		 ip4_hdr,
		 ip6_hdr,
		 ip6_ext,
		 tcp_hdr,
		 in_port,
		 in_phy_port,
		 metadata,
		 tunnel_id]},
	 {udp,
		[packet,
		 vlan_tag,
		 eth_type,
		 pbb_tag,
		 mpls_tag,
		 ip4_hdr,
		 ip6_hdr,
		 ip6_ext,
		 udp_hdr,
		 in_port,
		 in_phy_port,
		 metadata,
		 tunnel_id]},
	 {sctp,
		[packet,
		 vlan_tag,
		 eth_type,
		 pbb_tag,
		 mpls_tag,
		 ip4_hdr,
		 ip6_hdr,
		 ip6_ext,
		 sctp_hdr,
		 in_port,
		 in_phy_port,
		 metadata,
		 tunnel_id]},
	 {nonext,
		[packet,
		 vlan_tag,
		 eth_type,
		 pbb_tag,
		 mpls_tag,
		 ip4_hdr,
		 ip6_hdr,
		 ip6_ext,
		 in_port,
		 in_phy_port,
		 metadata,
		 tunnel_id]}].

%%EOF
