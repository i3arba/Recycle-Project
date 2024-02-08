//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol"; //Ferramenta do Foundry
import {BatchDistribution} from "../src/BatchDistribution.sol";//Contrato á ser deployado
import {DeployMindsFarmerMock} from "./DeployMindsFarmersMock.s.sol"; 

contract DeployBatchDistribution is Script {
	BatchDistribution batch; //Inicializa o contrato

	function run(address _owner, address _farmers) external returns(BatchDistribution){ //Função padrão	
		vm.startBroadcast(); //Inicia Execução
		
		batch = new BatchDistribution(_owner, _farmers);//Realiza o deploy do contrato.

		vm.stopBroadcast();//Encerra a Execução
		return batch;
	}
}