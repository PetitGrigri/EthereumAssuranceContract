pragma solidity ^0.4.0;


contract Assurance {


    address public owner;                                       // le propriétaire du smart contract
    mapping (address => uint) public adherentsDatesAdhesions;   // la liste des adhérents
    address[] public experts;                                   // la liste des adhérents

    // Permettrat un retour des informations
    event NewMember(address adherent, uint inscription);

    /*
     * Le constructeur.
     * Ici on enregistrera le propriétaire du smart contract afin de ne pas perdre l'argent lié au contrat
     */
    function assurance () public {
        owner = msg.sender;

    }

    /*
     * Permet de désigner un expert qui pourra valider des accidents (réserver au propriétaire du contract)
     */
    function ajouterExpert (address expert) public {
        experts.push(expert);

    }

    /*
     * Permet de s'enregistrer pour être gérer par le smart contract
     */
    function signUp() public {
        // Le cout de l'assurance est de 1 Ether
        require(msg.value == 1000000000000000000);
        adherentsDatesAdhesions[msg.sender] = now;
        NewMember(msg.sender,now);
    }


    /*
     * Permet a un assuré d'indiquer qu'il a un accident
     */
    function declareAccident (string type)  public {

    }


    /*
     * Permet a un expert de valider un accident déclarer par un assuré
     * (ce qui provoquera le remboursement des frais déclaré par l'expert)
     */
    function ValiderAccident() {

    }



    function fundtransfer(address etherreceiver, uint256 amount){
        require(msg.sender==owner);
        if(!etherreceiver.send(amount)){
           throw;
        }
    }

    //permet d'avoir le montant des fonds actuels
    function getFund() public constant returns (uint) {
        return this.balance;
    }

    //Permet de détruire le contrat et de renvoyer tout les fond au créateur du contrat
    function destroy() {
        require(msg.sender==owner);
        selfdestruct(msg.sender);
    }
}
