pragma solidity ^0.4.17;

contract Assurance {

    struct Adherent {
        string  mail;
        string  adresse1;
        string  adresse2;
        string  ville;
        string  codePostal;
        uint    dateAdhesion;
    }

    struct Expert {
        string  mail;
        uint    dateAdhesion;
    }

    struct Accident {
        string  typeDegats;
        uint    dateAccident;
        uint    dateValidation;
        uint    dateRefus;
        string  observationClient;
        string  observationExpert;
    }

    address public owner;                                       // le propriétaire du smart contract
    mapping (address => Adherent) public listeAdherents;        // la liste des adhérents
    mapping (address => Expert) public listeExperts;            // la liste des adhérents
    address[] public addressAdherents;
    address[] public addressExperts;

    Accident[] public accidents;



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
    function ajouterExpert (address adresseExpert, string mailExpert) public returns (string, uint) {
        require(msg.sender==owner);
        //création de l'expert
        Expert memory expert = Expert({mail:mailExpert, dateAdhesion:now});
        listeExperts[adresseExpert] = expert;

        addressExperts.push(adresseExpert);

        //retour de l'expert nouvellement crée
        return (expert.mail, expert.dateAdhesion);
    }

    /*
     * Permet de s'enregistrer pour être gérer par le smart contract
     */
    function signUp(string mailAdherent, string adresse1, string adresse2, string codePostal, string ville ) public returns (uint) {
        // Le cout de l'assurance est de 1 Ether
        require(msg.value == 1000000000000000000);

        //création de l'adhérent
        Adherent memory  adherent = Adherent({
            mail:mailAdherent,
            dateAdhesion:now,
            adresse1:adresse1,
            adresse2:adresse2,
            codePostal:codePostal,
            ville:ville
        });
        listeAdherents[msg.sender] = adherent;

        addressExperts.push(msg.sender);

        //retour de l'adhérent nouvellement crée
        return (adherent.dateAdhesion);
    }


    /*
     * Permet a un assuré d'indiquer qu'il a un accident
     */
    function declareAccident (string typeDegats)  public returns (uint) {
        Accident memory  accident = Accident({
            typeDegats:typeDegats,
            dateAccident:now,
            dateValidation:0,
            dateRefus:0,
            observationClient:"",
            observationExpert:""
        });
        accidents.push(accident);

        return (accident.dateAccident);
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
