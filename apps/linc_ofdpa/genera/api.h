//
// Selected functions of OF-DPA API
//

// Maybe in use - no RPC
//------------------------------------------------------------------------------

//// Initialization
//OFDPA_ERROR_t ofdpaClientInitialize(char *clientName);
//
//// Debugging and logging
//int ofdpaCltLogPrintf(int priority, char *fmt, ...);
//int ofdpaCltLogBuf(int priority, ofdpa_buffdesc message);
//int ofdpaCltDebugPrintf(const char *functionName, ofdpaComponentIds_t component, ofdpaDebugLevels_t verbosity, const char *format, ...);
//int ofdpaCltDebugBuf(ofdpa_buffdesc functionName, ofdpaComponentIds_t component, ofdpaDebugLevels_t verbosity, ofdpa_buffdesc message);
//
//// Event fd
//int ofdpaClientEventSockFdGet(void);
//int ofdpaClientPktSockFdGet(void);

// RPC
//------------------------------------------------------------------------------

// Flow entries
OFDPA_ERROR_t ofdpaFlowEntryInit(OFDPA_FLOW_TABLE_ID_t tableId, ofdpaFlowEntry_t *flow);
OFDPA_ERROR_t ofdpaFlowAdd(ofdpaFlowEntry_t *flow [in]);
OFDPA_ERROR_t ofdpaFlowModify(ofdpaFlowEntry_t *flow [in]);
OFDPA_ERROR_t ofdpaFlowDelete(ofdpaFlowEntry_t *flow [in]);
OFDPA_ERROR_t ofdpaFlowNextGet(ofdpaFlowEntry_t *flow [in], ofdpaFlowEntry_t *nextFlow);
OFDPA_ERROR_t ofdpaFlowStatsGet(ofdpaFlowEntry_t *flow [in], ofdpaFlowEntryStats_t *flowStats);
OFDPA_ERROR_t ofdpaFlowByCookieGet(uint64_t cookie, ofdpaFlowEntry_t *flow, ofdpaFlowEntryStats_t *flowStats);
OFDPA_ERROR_t ofdpaFlowByCookieDelete(uint64_t cookie);

// Groups
OFDPA_ERROR_t ofdpaGroupTypeGet(uint32_t groupId, uint32_t *type);
OFDPA_ERROR_t ofdpaGroupVlanGet(uint32_t groupId, uint32_t *vlanId);
OFDPA_ERROR_t ofdpaGroupPortIdGet(uint32_t groupId, uint32_t *portId);
OFDPA_ERROR_t ofdpaGroupIndexShortGet(uint32_t groupId, uint32_t *index);
OFDPA_ERROR_t ofdpaGroupIndexGet(uint32_t groupId, uint32_t *index);
OFDPA_ERROR_t ofdpaGroupTypeSet(uint32_t *groupId [inout], uint32_t type);
OFDPA_ERROR_t ofdpaGroupVlanSet(uint32_t *groupId [inout], uint32_t vlanId);
OFDPA_ERROR_t ofdpaGroupOverlayTunnelIdSet(uint32_t *groupId [inout], uint32_t tunnelId);
OFDPA_ERROR_t ofdpaGroupOverlaySubTypeSet(uint32_t *groupId [inout], OFDPA_L2_OVERLAY_SUBTYPE_t subType);
OFDPA_ERROR_t ofdpaGroupOverlayIndexSet(uint32_t *groupId [inout], uint32_t index);
OFDPA_ERROR_t ofdpaGroupPortIdSet(uint32_t *groupId [inout], uint32_t portId);
OFDPA_ERROR_t ofdpaGroupIndexShortSet(uint32_t *groupId [inout], uint32_t index);
OFDPA_ERROR_t ofdpaGroupIndexSet(uint32_t *groupId [inout], uint32_t index);
OFDPA_ERROR_t ofdpaGroupDecode(uint32_t groupId, char *outBuf, int bufSize); // special
OFDPA_ERROR_t ofdpaGroupEntryInit(OFDPA_GROUP_ENTRY_TYPE_t groupType, ofdpaGroupEntry_t *group);
OFDPA_ERROR_t ofdpaGroupAdd(ofdpaGroupEntry_t *group [in]);
OFDPA_ERROR_t ofdpaGroupDelete(uint32_t groupId);
OFDPA_ERROR_t ofdpaGroupNextGet(uint32_t groupId, ofdpaGroupEntry_t *nextGroup);
OFDPA_ERROR_t ofdpaGroupTypeNextGet(uint32_t groupId,
                                    OFDPA_GROUP_ENTRY_TYPE_t groupType,
                                    ofdpaGroupEntry_t *nextGroup);
OFDPA_ERROR_t ofdpaGroupStatsGet(uint32_t groupId, ofdpaGroupEntryStats_t *groupStats);
OFDPA_ERROR_t ofdpaGroupBucketEntryInit(OFDPA_GROUP_ENTRY_TYPE_t groupType, ofdpaGroupBucketEntry_t *bucket);
OFDPA_ERROR_t ofdpaGroupBucketEntryAdd(ofdpaGroupBucketEntry_t *bucket [in]);
OFDPA_ERROR_t ofdpaGroupBucketEntryDelete(uint32_t groupId, uint32_t bucketIndex);
OFDPA_ERROR_t ofdpaGroupBucketsDeleteAll(uint32_t groupId);
OFDPA_ERROR_t ofdpaGroupBucketEntryGet(uint32_t groupId, uint32_t bucketIndex,
                                       ofdpaGroupBucketEntry_t *groupBucket);
OFDPA_ERROR_t ofdpaGroupBucketEntryFirstGet(uint32_t groupId,
                                            ofdpaGroupBucketEntry_t *firstGroupBucket);
OFDPA_ERROR_t ofdpaGroupBucketEntryNextGet(uint32_t groupId, uint32_t bucketIndex,
                                           ofdpaGroupBucketEntry_t *nextBucketEntry);
OFDPA_ERROR_t ofdpaGroupBucketEntryModify(ofdpaGroupBucketEntry_t *bucket [in]);
OFDPA_ERROR_t ofdpaGroupTableInfoGet(OFDPA_GROUP_ENTRY_TYPE_t groupType, ofdpaGroupTableInfo_t *info);

// Ports
void ofdpaPortTypeGet(uint32_t portNum, uint32_t *type);
void ofdpaPortTypeSet(uint32_t *portNum [inout], uint32_t type);
void ofdpaPortIndexGet(uint32_t portNum, uint32_t *index);
void ofdpaPortIndexSet(uint32_t *portNum [inout], uint32_t index);
OFDPA_ERROR_t ofdpaPortNextGet(uint32_t portNum, uint32_t *nextPortNum);
OFDPA_ERROR_t ofdpaPortMacGet(uint32_t portNum, ofdpaMacAddr_t *mac);
OFDPA_ERROR_t ofdpaPortNameGet(uint32_t portNum, ofdpa_buffdesc *name);	// special
OFDPA_ERROR_t ofdpaPortStateGet(uint32_t  portNum, OFDPA_PORT_STATE_t  *state);
OFDPA_ERROR_t ofdpaPortConfigSet(uint32_t portNum, OFDPA_PORT_CONFIG_t config);
OFDPA_ERROR_t ofdpaPortConfigGet(uint32_t portNum, OFDPA_PORT_CONFIG_t  *config);
OFDPA_ERROR_t ofdpaPortMaxSpeedGet(uint32_t portNum, uint32_t  *maxSpeed);
OFDPA_ERROR_t ofdpaPortCurrSpeedGet(uint32_t portNum, uint32_t  *currSpeed);
OFDPA_ERROR_t ofdpaPortFeatureGet(uint32_t portNum, ofdpaPortFeature_t *feature);
OFDPA_ERROR_t ofdpaPortAdvertiseFeatureSet(uint32_t portNum, uint32_t advertise);
OFDPA_ERROR_t ofdpaPortStatsClear(uint32_t portNum);
OFDPA_ERROR_t ofdpaPortStatsGet(uint32_t portNum, ofdpaPortStats_t *stats);

// Packet-out
OFDPA_ERROR_t ofdpaPktSend(ofdpa_buffdesc *pkt, uint32_t flags, uint32_t outPortNum, uint32_t inPortNum); // special
OFDPA_ERROR_t ofdpaMaxPktSizeGet(uint32_t *pktSize);

// Events
OFDPA_ERROR_t ofdpaPktReceive(struct timeval *timeout, ofdpaPacket_t *pkt); // special
OFDPA_ERROR_t ofdpaEventReceive(struct timeval *timeout); // special
OFDPA_ERROR_t ofdpaPortEventNextGet(ofdpaPortEvent_t *eventData);
OFDPA_ERROR_t ofdpaFlowEventNextGet(ofdpaFlowEvent_t *eventData);

// Tables
OFDPA_ERROR_t ofdpaFlowTableInfoGet(OFDPA_FLOW_TABLE_ID_t tableId, ofdpaFlowTableInfo_t *info);

// Queues
OFDPA_ERROR_t ofdpaNumQueuesGet(uint32_t portNum, uint32_t *numQueues);
OFDPA_ERROR_t ofdpaQueueStatsGet(uint32_t portNum, uint32_t queueId, ofdpaPortQueueStats_t *stats);
OFDPA_ERROR_t ofdpaQueueStatsClear(uint32_t portNum, uint32_t queueId);
OFDPA_ERROR_t ofdpaQueueRateSet(uint32_t portNum, uint32_t queueId, uint32_t minRate, uint32_t maxRate);
OFDPA_ERROR_t ofdpaQueueRateGet(uint32_t portNum, uint32_t queueId, uint32_t *minRate, uint32_t *maxRate);

// Not used
//------------------------------------------------------------------------------

//// Tunnels
//OFDPA_ERROR_t ofdpaTunnelPortCreate(uint32_t portNum, ofdpa_buffdesc *name, ofdpaTunnelPortConfig_t *config);
//OFDPA_ERROR_t ofdpaTunnelPortDelete(uint32_t portNum);
//OFDPA_ERROR_t ofdpaTunnelPortGet(uint32_t portNum,
//                                 ofdpaTunnelPortConfig_t *config,
//                                 ofdpaTunnelPortStatus_t *status);
//OFDPA_ERROR_t ofdpaTunnelPortNextGet(uint32_t portNum, uint32_t *nextPortNum);
//OFDPA_ERROR_t ofdpaTunnelPortTenantAdd(uint32_t portNum, uint32_t tunnelId);
//OFDPA_ERROR_t ofdpaTunnelPortTenantDelete(uint32_t portNum, uint32_t tunnelId);
//OFDPA_ERROR_t ofdpaTunnelPortTenantGet(uint32_t portNum, uint32_t tunnelId, ofdpaTunnelPortTenantStatus_t *status);
//OFDPA_ERROR_t ofdpaTunnelPortTenantNextGet(uint32_t portNum, uint32_t tunnelId, uint32_t *nextTunnelId);
//OFDPA_ERROR_t ofdpaTunnelTenantCreate(uint32_t tunnelId, ofdpaTunnelTenantConfig_t *config);
//OFDPA_ERROR_t ofdpaTunnelTenantDelete(uint32_t tunnelId);
//OFDPA_ERROR_t ofdpaTunnelTenantGet(uint32_t tunnelId,
//                                   ofdpaTunnelTenantConfig_t *config,
//                                   ofdpaTunnelTenantStatus_t *status);
//OFDPA_ERROR_t ofdpaTunnelTenantNextGet(uint32_t tunnelId, uint32_t *nextTunnelId);
//OFDPA_ERROR_t ofdpaTunnelNextHopCreate(uint32_t nextHopId, ofdpaTunnelNextHopConfig_t *config);
//OFDPA_ERROR_t ofdpaTunnelNextHopDelete(uint32_t nextHopId);
//OFDPA_ERROR_t ofdpaTunnelNextHopModify(uint32_t nextHopId, ofdpaTunnelNextHopConfig_t *config);
//OFDPA_ERROR_t ofdpaTunnelNextHopGet(uint32_t nextHopId,
//                                    ofdpaTunnelNextHopConfig_t *config,
//                                    ofdpaTunnelNextHopStatus_t *status);
//OFDPA_ERROR_t ofdpaTunnelNextHopNextGet(uint32_t nextHopId, uint32_t *nextNextHopId);
//OFDPA_ERROR_t ofdpaTunnelEcmpNextHopGroupCreate(uint32_t ecmpNextHopGroupId, ofdpaTunnelEcmpNextHopGroupConfig_t *config);
//OFDPA_ERROR_t ofdpaTunnelEcmpNextHopGroupDelete(uint32_t ecmpNextHopGroupId);
//OFDPA_ERROR_t ofdpaTunnelEcmpNextHopGroupGet(uint32_t ecmpNextHopGroupId,
//                                             ofdpaTunnelEcmpNextHopGroupConfig_t *config,
//                                             ofdpaTunnelEcmpNextHopGroupStatus_t *status);
//OFDPA_ERROR_t ofdpaTunnelEcmpNextHopGroupNextGet(uint32_t ecmpNextHopGroupId, uint32_t *nextEcmpNextHopGroupId);
//OFDPA_ERROR_t ofdpaTunnelEcmpNextHopGroupMaxMembersGet(uint32_t *maxMemberCount);
//OFDPA_ERROR_t ofdpaTunnelEcmpNextHopGroupMemberAdd(uint32_t ecmpNextHopGroupId, uint32_t nextHopId);
//OFDPA_ERROR_t ofdpaTunnelEcmpNextHopGroupMemberDelete(uint32_t ecmpNextHopGroupId, uint32_t nextHopId);
//OFDPA_ERROR_t ofdpaTunnelEcmpNextHopGroupMemberGet(uint32_t ecmpNextHopListGroupId, uint32_t nextHopId);
//OFDPA_ERROR_t ofdpaTunnelEcmpNextHopGroupMemberNextGet(uint32_t ecmpNextHopListGroupId, uint32_t nextHopId, uint32_t *nextNextHopId);
//
//// Vendor extension
//OFDPA_ERROR_t ofdpaSourceMacLearningSet(OFDPA_CONTROL_t mode, ofdpaSrcMacLearnModeCfg_t *srcMacLearnModeCfg);
//OFDPA_ERROR_t ofdpaSourceMacLearningGet(OFDPA_CONTROL_t *mode, ofdpaSrcMacLearnModeCfg_t *srcMacLearnModeCfg);
//
//// Debug
//int ofdpaDebugLvl(int lvl);
//int ofdpaDebugLvlGet(void);
//int ofdpaComponentNameGet(int component, ofdpa_buffdesc *name);
//int ofdpaDebugComponentSet(int component, int enable);
//int ofdpaDebugComponentGet(int component);
//int ofdpaBcmCommand(ofdpa_buffdesc buffer);

//EOF
