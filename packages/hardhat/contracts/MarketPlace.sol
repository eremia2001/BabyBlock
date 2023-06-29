// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract MarketPlace {
    struct Item {
        uint id;
        address payable originOwner;
        string name;
        uint16 price;
        string description;
    }

    enum TransactionState {
        AWAITING_PAYMENT,
        AWAITING_CONFIRMATION,
        COMPLETED
    }

    struct Transaction {
        TransactionState state;
        address buyer;
    }

    mapping(uint => Item) public itemList;
    mapping(uint => address) public itemToOwner;
    mapping(address => uint) ownerItemCount;
    mapping(uint => Transaction) public transactions;

    uint public itemCount;

    event NewItem(uint itemId, address owner, string name);

    function addItem(
        string memory _name,
        uint16 _price,
        string memory _description
    ) public {
        itemList[itemCount] = Item(
            itemCount,
            payable(msg.sender),
            _name,
            _price,
            _description
        );
        itemToOwner[itemCount] = msg.sender;
        ownerItemCount[msg.sender]++;
        emit NewItem(itemCount, msg.sender, _name);
        itemCount++;
    }

    function buyItem(uint _itemId) public payable {
        // Der Verkäufer muss jmd anders sein als der Käufer
        require(msg.sender != itemList[_itemId].originOwner);
        // Das Item muss jemandem gehören
        require(itemToOwner[_itemId] != address(0));
        // Der Preis muss mindestens so hoch sein wie der Preis des Artikels
        require(msg.value >= itemList[_itemId].price, "Price is not enough.");

        // Starte die Transaktion und speichere den Käufer und den Zustand
        transactions[_itemId] = Transaction(
            TransactionState.AWAITING_CONFIRMATION,
            msg.sender
        );
    }

    function confirmTransaction(uint _itemId) public {
        // Nur der Verkäufer kann die Transaktion bestätigen
        require(
            msg.sender == itemList[_itemId].originOwner,
            "Only the seller can confirm the transaction."
        );
        require(
            transactions[_itemId].state ==
                TransactionState.AWAITING_CONFIRMATION,
            "The transaction is not awaiting confirmation."
        );

        // Übertrage das Eigentum und das Geld
        ownerItemCount[itemList[_itemId].originOwner]--;
        itemList[_itemId].originOwner.transfer(itemList[_itemId].price);
        itemToOwner[_itemId] = transactions[_itemId].buyer;
        ownerItemCount[transactions[_itemId].buyer]++;
        transactions[_itemId].state = TransactionState.COMPLETED;
    }
}
