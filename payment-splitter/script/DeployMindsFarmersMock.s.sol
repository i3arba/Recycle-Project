//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol"; //Ferramenta do Foundry
import {MindsFarmerMock} from "../test/mocks/MindsFarmersMock.sol";//Contrato á ser deployado;

contract DeployMindsFarmerMock is Script {
	MindsFarmerMock farmers; //Inicializa o contrato

	function run() external returns(MindsFarmerMock){ //Função padrão
		
		vm.startBroadcast(); //Inicia Execução
		
		farmers = new MindsFarmerMock();//Realiza o deploy do contrato.

		vm.stopBroadcast();//Encerra a Execução

		return farmers;
	}
}