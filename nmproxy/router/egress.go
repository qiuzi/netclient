package router

import (
	"github.com/gravitl/netmaker/logger"
	"github.com/gravitl/netmaker/models"
)

func SetEgressRoutes(server string, egressUpdate map[string]models.EgressInfo) error {
	logger.Log(0, "----> setting ingress routes")
	ruleTable := fwCrtl.FetchRuleTable(server, egressTable)
	for egressNodeID, ruleCfg := range ruleTable {

		if _, ok := egressUpdate[egressNodeID]; !ok {
			// egress GW is deleted, flush out all rules
			fwCrtl.RemoveRoutingRules(server, egressTable, egressNodeID)
			continue
		}
		egressInfo := egressUpdate[egressNodeID]
		for peerKey := range ruleCfg.rulesMap {
			if _, ok := egressInfo.GwPeers[peerKey]; !ok && peerKey != egressNodeID {
				// peer is deleted for ext client, remove routing rule
				fwCrtl.DeleteRoutingRule(server, egressTable, egressNodeID, peerKey)
			}
		}
	}

	for egressNodeID, egressInfo := range egressUpdate {
		if _, ok := ruleTable[egressNodeID]; !ok {
			// set up rules for the GW on first time creation
		} else {
			peerRules := ruleTable[egressNodeID]
			for _, peer := range egressInfo.GwPeers {
				if _, ok := peerRules.rulesMap[peer.PeerKey]; !ok {
					// add egress rule for the peer
				}
			}
		}
	}
	return nil
}
