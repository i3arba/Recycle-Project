# RecyclePaymentSplitterUni
RecyclePaymentSplitterUni.verifyContractBalanceToDistribution(uint256) (src/RecyclePaymentSplitterUni.sol#39-83) uses a dangerous strict equality:
        - (address(this).balance + s_totalValueWithdrawn) == s_totalValueReceived (src/RecyclePaymentSplitterUni.sol#46)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#dangerous-strict-equalities


# RecyclePaymentSplitter
INFO:Detectors:
RecyclePaymentSplitter.verifyContractBalanceToDistribution(uint256[]) (src/RecyclePaymentSplitter.sol#39-54) uses a dangerous strict equality:
        - (address(this).balance + s_totalValueWithdrawn) == s_totalValueReceived (src/RecyclePaymentSplitter.sol#44)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#dangerous-strict-equalities

INFO:Detectors:
Reentrancy in RecyclePaymentSplitter._withdraw(uint256[]) (src/RecyclePaymentSplitter.sol#60-84):
        External calls:
        - Address.sendValue(address(msg.sender),valueToWithdraw) (src/RecyclePaymentSplitter.sol#82)
        State variables written after the call(s):
        - s_totalValueWithdrawn += valueToWithdraw (src/RecyclePaymentSplitter.sol#77)
        RecyclePaymentSplitter.s_totalValueWithdrawn (src/RecyclePaymentSplitter.sol#17) can be used in cross function reentrancies:
        - RecyclePaymentSplitter._withdraw(uint256[]) (src/RecyclePaymentSplitter.sol#60-84)
        - RecyclePaymentSplitter.verifyContractBalanceToDistribution(uint256[]) (src/RecyclePaymentSplitter.sol#39-54)
        - s_valueAlreadyPaidPerNFT[_farmersId[i]] += valueToWithdraw (src/RecyclePaymentSplitter.sol#76)
        RecyclePaymentSplitter.s_valueAlreadyPaidPerNFT (src/RecyclePaymentSplitter.sol#24) can be used in cross function reentrancies:
        - RecyclePaymentSplitter._withdraw(uint256[]) (src/RecyclePaymentSplitter.sol#60-84)
        - RecyclePaymentSplitter.getValueWithdrawnPerFarmer(uint256) (src/RecyclePaymentSplitter.sol#90-92)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities-1