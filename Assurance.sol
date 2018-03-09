pragma solidity ^0.4.17;

contract Assurance {

    struct Adherent {
        string  mail;
        string  adresse1;
        string  adresse2;
        string  ville;
        string  codePostal;
        uint    dateAdhesion;
        uint[]  accidents;
    }

    struct Expert {
        string  mail;
        uint    dateAdhesion;
    }

    struct Accident {
        address adherentAddress;
        string  typeDegats;
        uint    dateAccident;
        uint    dateValidation;
        uint    dateRefus;
        uint    montantRemoursement;
        string  observationExpert;
    }

    address private owner;                                       // le propriétaire du smart contract

    mapping (address => Adherent) public listeAdherents;        // la liste des adhérents
    mapping (address => Expert) public listeExperts;            // la liste des adhérents
    Accident[] private accidents;                                // contient la liste des accidents

    address[] private addressAdherents;                         // contient les adresses des adhérents
    address[] private addressExperts;                           // contient les adresses des experts
    uint[] private accidentsId;                                 // contient les id des accidents  (index dans le tableau)

    /*
     * Le constructeur.
     * Ici on enregistrera le propriétaire du smart contract afin de ne pas perdre l'argent lié au contrat
     */
    function Assurance () public {
        owner = msg.sender;
    }

    /*
     * Permet d'avoir le owner
     */
    function getOwner() public constant returns (address) {
       return owner;
    }
    
    /*
     * Permet d'avoir l'accident
     */
    function getAccident(uint index) public constant returns (address, string, uint, uint, uint, uint, string) {
        
        Accident accident = accidents[index];
        return (accident.adherentAddress, accident.typeDegats, accident.dateAccident, 
                    accident.dateValidation, accident.dateRefus, 
                    accident.montantRemoursement, accident.observationExpert);
    }

    /*
     * Permet d'accéder à la liste des address (ethereum) des experts
     */
    function getExpertsAddress() public constant returns (address[] ) {
       return addressExperts;
    }

    /*
     * Permet d'accéder à la liste des address (ethereum) des adhérents
     */
    function getAdherentsAddress() public constant returns (address[] ) {
       return addressAdherents;
    }
    /*
     * Permet d'accéder aux Id des accidents
     */
    function getAccidentsId() public constant returns (uint[] ) {
       return accidentsId;
    }


    //permet d'avoir le montant des fonds actuels
    function getFund() public constant returns (uint) {
        return this.balance;
    }

    /*
     * Permet d'accéder à la liste des accidents (id) d'un adhérent
     */
    function getAdherentsAccidents(address addressAdherent) public constant returns (uint[] ) {
       return listeAdherents[addressAdherent].accidents;
    }

    /*
     * Permet de désigner un expert qui pourra valider des accidents (réserver au propriétaire du contract)
     * "0x94578E2233926ab14DB8777Bc22853a62397f89d", "forever.young@yopmail.com"
     * "0x6D61133AfDfD30f56F0DC3f2D975A32e358986A9", "owner.expert@yopmail.com"
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
     * "john.doe@yopmail.com", "50 rue du test", "", "75012","Paris"
     * "titi@yopmail.com", "50 rue du test", "chez John", "75012","Paris"
     */
    function signUp(string mailAdherent, string adresse1, string adresse2, string codePostal, string ville) payable returns (uint) {
        // Le cout de l'assurance est de 1 Ether
        require(msg.value == 1000000000000000000);

        uint[] memory accidentsAdherents;

        //création de l'adhérent
        Adherent memory  adherent = Adherent({
            mail:mailAdherent,
            adresse1:adresse1,
            adresse2:adresse2,
            codePostal:codePostal,
            ville:ville,
            dateAdhesion:now,
            accidents:accidentsAdherents
        });

        listeAdherents[msg.sender] = adherent;
        addressAdherents.push(msg.sender);

        //retour de l'adhérent nouvellement crée
        return (adherent.dateAdhesion);
    }




    /*
     * Permet a un assuré d'indiquer qu'il a un accident
     * "Incendie"
     * "Dégats des eaux"
     */
    function declareAccident (string typeDegats)  public returns (uint) {
        //seul le propriétaire du contract peut déclarer un accident ou l'adhérent
        require (listeAdherents[msg.sender].dateAdhesion != 0);
        require (listeAdherents[msg.sender].dateAdhesion < (listeAdherents[msg.sender].dateAdhesion + 1 years));

        //Création de l'accident
        Accident memory  accident = Accident({
            adherentAddress:msg.sender,
            typeDegats:typeDegats,
            dateAccident:now,
            dateValidation:0,
            dateRefus:0,
            observationExpert:"",
            montantRemoursement:0
        });
        accidents.push(accident);

        listeAdherents[msg.sender].accidents.push(accidents.length-1);
        accidentsId.push(accidents.length-1);

        return (accident.dateAccident);
    }


    /*
     * Permet a un expert de valider un accident déclarer par un assuré
     * (ce qui provoquera le remboursement des frais déclaré par l'expert)
     * 0, "0x6d61133afdfd30f56f0dc3f2d975a32e358986a9", "Incendie lié à une usure des conduites de gaz.", "100000000000000"
     * 1, "0x6d61133afdfd30f56f0dc3f2d975a32e358986a9", "Voisin du dessus qui a souhaité faire des réparations avec du scotch.", "100000000000000"
     */
    function validerAccident(uint accidentId, address adherentAddress, string observationExpert, uint montantRemoursement) returns (string){
        require(listeExperts[msg.sender].dateAdhesion != 0);
        require(montantRemoursement <= this.balance);

        if ((accidents[accidentId].adherentAddress != address(0x0)) && (accidents[accidentId].adherentAddress == adherentAddress))  {
            accidents[accidentId].dateValidation = now;
            accidents[accidentId].observationExpert = observationExpert;
            accidents[accidentId].montantRemoursement = montantRemoursement;

            if(!accidents[accidentId].adherentAddress.send(montantRemoursement)){
                return("Validation réalisée. Paiement validé.");
            } else {

                return("Validation réalisée. Erreur lors du paiement.");
            }

        } else {
            return("Validation non authorisé");
        }
    }

        /*
     * Permet a un expert de valider un accident déclarer par un assuré
     * (ce qui provoquera le remboursement des frais déclaré par l'expert)
     * 0, "0x6d61133afdfd30f56f0dc3f2d975a32e358986a9", "Faux devis."
     * 1, "0x6d61133afdfd30f56f0dc3f2d975a32e358986a9", "Faux devis."
     */
    function refuserAccident(uint accidentId, address adherentAddress, string observationExpert) returns (string){
        require(listeExperts[msg.sender].dateAdhesion != 0);

        if ((accidents[accidentId].adherentAddress != address(0x0)) && (accidents[accidentId].adherentAddress == adherentAddress))  {
            accidents[accidentId].dateRefus = now;
            accidents[accidentId].observationExpert = observationExpert;

            return("Refus validé.");
        } else {
            return("Refus non authorisé.");
        }
    }


    //Permet de détruire le contrat et de renvoyer tout les fond au créateur du contrat
    function destroy() {
        require(msg.sender==owner);
        selfdestruct(msg.sender);
    }
}