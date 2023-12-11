//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/*
 * @title GroceryShop
 * @dev A smart contract to keep track of grocery items and its transactions
 */
contract GroceryShop {
    address public owner;
    uint256 public purchaseId;

    struct Grocery {
        string itemName;
        uint256 itemStock;
    }

    struct PurchaseDetail {
        address buyer;
        GroceryType itemType;
        uint256 totalItemBought;
    }

    enum GroceryType {
        Milk,
        Bread,
        Egg
    }

    mapping(GroceryType => Grocery) groceryItem;
    mapping(GroceryType => uint256) itemPrice;
    mapping(uint256 => PurchaseDetail) purchaseReceipt;

    /*
     * @dev Smart Contract Constructor:
     * - Set Contract Creator as Owner
     * - Set all item stocks to 10
     * - Set all item price to 0.001 ether
     */
    constructor() {
        owner = msg.sender;
        //Default: Set the Item stocks to 10 and price to 0.001 ETH
        groceryItem[GroceryType.Milk] = Grocery("Milk", 10);
        groceryItem[GroceryType.Bread] = Grocery("Bread", 10);
        groceryItem[GroceryType.Egg] = Grocery("Egg", 10);

        itemPrice[GroceryType.Milk]  = (0.001 ether);
        itemPrice[GroceryType.Bread] = (0.001 ether);
        itemPrice[GroceryType.Egg]   = (0.001 ether);
    }

    /*
     * @dev Modifier that only allows owner to call a function
     */
    modifier onlyOwner(){
        require(msg.sender == owner, "Only Allowed for Owner");
        _;
    }

    /*
     * @dev Modifier to check a number must be greater than zero
     * @param number The number to be checked
     */
    modifier numberChecking(uint256 number){
        require(number > 0, "Number must be greater than 0");
        _;
    }
    
    /*
     * @dev Function to add an item into the grocery stock (ONLY ALLOWED FOR OWNER)
     * @param _groceryType The number/code of the grocery
     * @param _totalAdded The number of new item to be added
     */
    function add(GroceryType _groceryType, uint _totalAdded)
    public onlyOwner numberChecking(_totalAdded){
        groceryItem[_groceryType].itemStock += _totalAdded;
    }

    /*
     * @dev Function to update the price of an item (ONLY ALLOWED FOR OWNER)
     * @param _groceryType The number/code of the grocery
     * @param _newPrice The new updated price of the item
     */
    function setPrice(GroceryType _groceryType, uint _newPrice)
    public onlyOwner numberChecking(_newPrice){
        itemPrice[_groceryType] = _newPrice;
    }

    /*
     * @dev Function to buy an item from the grocery
     * @param _groceryType The number/code of the grocery
     * @param _totalBought The total item to be bought 
     */
    function buy(GroceryType _groceryType, uint _totalBought)
    public payable numberChecking(_totalBought){
        //Reject the transaction if the item stock is not enough
        require(groceryItem[_groceryType].itemStock >= _totalBought, "Not Enough Stock");

        uint total = _totalBought * itemPrice[_groceryType];
        //Reject the transaction if the provided balance by user is not enough
        require(msg.value >= total, "Insufficient Balance");

        purchaseId++; //Move to next purchase ID
        groceryItem[_groceryType].itemStock -= _totalBought;

        //Add Receipt Information
        purchaseReceipt[purchaseId]= PurchaseDetail(
            msg.sender,
            _groceryType,
            _totalBought
        );
    }

    /*
     * @dev Function to withdraw the contract balance (ONLY ALLOWED FOR OWNER)
     */
    function withdraw() public onlyOwner{
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Withdrawal Failed");
    }

    /*
     * @dev Function to check the receipt information of a transaction
     * @param _purchaseId The receipt ID of the transaction
     * @return The address of the buyer
     * @return The number/code of the bought item
     * @return The total item bought 
     */
    function checkReceipt(uint256 _purchaseId)
    public view returns(address, GroceryType, uint256){
        return(
            purchaseReceipt[_purchaseId].buyer,
            purchaseReceipt[_purchaseId].itemType,
            purchaseReceipt[_purchaseId].totalItemBought
        );
    }

    /*
     * @dev Function to check the name of an item
     * @param  _groceryType The number/code of the grocery
     * @return A string of the item name
     */
    function checkName(GroceryType _groceryType) public view returns(string memory)
    {
        return (groceryItem[_groceryType].itemName);
    }

    /*
     * @dev    Function to check the stock of an item
     * @param  _groceryType The number/code of the grocery
     * @return The number of item stock left
     */
    function checkStock(GroceryType _groceryType) public view returns(uint256)
    {
        return (groceryItem[_groceryType].itemStock);
    }

    /*
     * @dev Function to check the price of an item
     * @param  _groceryType The number/code of the grocery
     * @return The current price of the item
     */
    function checkPrice(GroceryType _groceryType) public view returns(uint256)
    {
        return (itemPrice[_groceryType]);
    }

}
