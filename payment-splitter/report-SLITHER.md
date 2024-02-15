# INFO:Detectors:
RecyclePaymentSplitter.verifyAndWithdraw(uint256[]) (src/RecyclePaymentSplitter.sol#70-85) uses a dangerous strict equality:
- (address(this).balance + s_totalValueWithdrawn) == s_totalValueReceived (src/RecyclePaymentSplitter.sol#75)

RecyclePaymentSplitterUni.verifyContractBalanceToDistribution(uint256) (src/RecyclePaymentSplitterUni.sol#38-82) uses a dangerous strict equality:
- (address(this).balance + s_totalValueWithdrawn) == s_totalValueReceived (src/RecyclePaymentSplitterUni.sol#45)

**Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#dangerous-strict-equalities**

# INFO:Detectors:
Address._revert(bytes) (lib/openzeppelin-contracts/contracts/utils/Address.sol#146-158) uses assembly
- INLINE ASM (lib/openzeppelin-contracts/contracts/utils/Address.sol#151-154)
- 
**Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#assembly-usage**

# INFO:Detectors:
Different versions of Solidity are used:
- Version used: ['0.8.20', '^0.8.20']
- 0.8.20 (src/RecyclePaymentSplitter.sol#2)
- 0.8.20 (src/RecyclePaymentSplitterUni.sol#2)
- ^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol#4)
- ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/Address.sol#4)
- ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol#4)
- ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#4)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#different-pragma-directives-are-used

# INFO:Detectors:
Pragma version^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol#4) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

Pragma version^0.8.20 (lib/openzeppelin-contracts/contracts/utils/Address.sol#4) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

Pragma version^0.8.20 (lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol#4) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

Pragma version^0.8.20 (lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#4) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

Pragma version0.8.20 (src/RecyclePaymentSplitter.sol#2) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

Pragma version0.8.20 (src/RecyclePaymentSplitterUni.sol#2) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

**Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-versions-of-solidity**

# INFO:Detectors:
Low level call in Address.sendValue(address,uint256) (lib/openzeppelin-contracts/contracts/utils/Address.sol#41-50):
- (success) = recipient.call{value: amount}() (lib/openzeppelin-contracts/contracts/utils/Address.sol#46)

Low level call in Address.functionCallWithValue(address,bytes,uint256) (lib/openzeppelin-contracts/contracts/utils/Address.sol#83-89):
- (success,returndata) = target.call{value: value}(data) (lib/openzeppelin-contracts/contracts/utils/Address.sol#87)

Low level call in Address.functionStaticCall(address,bytes) (lib/openzeppelin-contracts/contracts/utils/Address.sol#95-98):
- (success,returndata) = target.staticcall(data) (lib/openzeppelin-contracts/contracts/utils/Address.sol#96)

Low level call in Address.functionDelegateCall(address,bytes) (lib/openzeppelin-contracts/contracts/utils/Address.sol#104-107):
- (success,returndata) = target.delegatecall(data) (lib/openzeppelin-contracts/contracts/utils/Address.sol#105)

**Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#low-level-calls**

# INFO:Detectors:
Event RecyclePaymentSplitter.RecyclePaymentSplitter__Withdrawal(address,uint256) (src/RecyclePaymentSplitter.sol#46) is not in CapWords

Event RecyclePaymentSplitter.RecyclePaymentSplitter__ValuePerNftUpdated(uint256) (src/RecyclePaymentSplitter.sol#48) is not in CapWords

Parameter RecyclePaymentSplitter.verifyAndWithdraw(uint256[])._farmersId (src/RecyclePaymentSplitter.sol#70) is not in mixedCase

Parameter RecyclePaymentSplitter.getValueWithdrawnPerFarmer(uint256)._tokenId (src/RecyclePaymentSplitter.sol#123) is not in mixedCase

Variable RecyclePaymentSplitter.MINDS_FARMER (src/RecyclePaymentSplitter.sol#39) is not in mixedCase

Event RecyclePaymentSplitterUni.RecyclePaymentSplitter__Withdrawal(address,uint256) (src/RecyclePaymentSplitterUni.sol#25) is not in CapWords

Event RecyclePaymentSplitterUni.RecyclePaymentSplitter__ValueReceived(uint256,uint256) (src/RecyclePaymentSplitterUni.sol#26) is not in CapWords

Parameter RecyclePaymentSplitterUni.verifyContractBalanceToDistribution(uint256)._farmersId (src/RecyclePaymentSplitterUni.sol#38) is not in mixedCase

Parameter RecyclePaymentSplitterUni.getValueWithdrawnPerFarmer(uint256)._tokenId (src/RecyclePaymentSplitterUni.sol#88) is not in mixedCase

Variable RecyclePaymentSplitterUni.MINDS_FARMER (src/RecyclePaymentSplitterUni.sol#21) is not in mixedCase

**Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions**