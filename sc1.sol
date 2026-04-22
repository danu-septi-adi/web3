// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract DSystemToken {
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    string public tokenLogoURL;
    address public immutable owner; 
    
    uint256 public tokensPerEth = 10000;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event MetadataUpdated(string newName, string newSymbol, string newLogo);

    error NotOwner();
    error LowBalance();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor(string memory _name, string memory _symbol, uint256 _supply, address _owner, string memory _logo) {
        name = _name;
        symbol = _symbol;
        tokenLogoURL = _logo;
        owner = _owner;
        uint256 initialSupply;
        unchecked { initialSupply = _supply * 10**18; }
        totalSupply = initialSupply;
        balanceOf[_owner] = initialSupply;
        emit Transfer(address(0), _owner, initialSupply);
    }

    receive() external payable {
        if (msg.value == 0) revert LowBalance();
        uint256 amount;
        unchecked { amount = msg.value * tokensPerEth; }
        if (balanceOf[owner] < amount) revert LowBalance();

        balanceOf[owner] -= amount;
        balanceOf[msg.sender] += amount;
        emit Transfer(owner, msg.sender, amount);
    }

    function transfer(address to, uint256 value) external returns (bool) {
        if (balanceOf[msg.sender] < value) revert LowBalance();
        unchecked {
            balanceOf[msg.sender] -= value;
            balanceOf[to] += value;
        }
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function setRate(uint256 _newRate) external onlyOwner {
        tokensPerEth = _newRate;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        uint256 mintAmount;
        unchecked { mintAmount = amount * 10**18; }
        totalSupply += mintAmount;
        balanceOf[to] += mintAmount;
        emit Transfer(address(0), to, mintAmount);
    }

    function burn(uint256 amount) external {
        uint256 burnAmount;
        unchecked { burnAmount = amount * 10**18; }
        if (balanceOf[msg.sender] < burnAmount) revert LowBalance();
        unchecked {
            balanceOf[msg.sender] -= burnAmount;
            totalSupply -= burnAmount;
        }
        emit Transfer(msg.sender, address(0), burnAmount);
    }

    function updateMetadata(string calldata _newName, string calldata _newSymbol, string calldata _newLogo) external onlyOwner {
        name = _newName;
        symbol = _newSymbol;
        tokenLogoURL = _newLogo;
        emit MetadataUpdated(_newName, _newSymbol, _newLogo);
    }

    function withdrawETH() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}

contract TokenFactory {
    address[] public allTokens;
    event TokenCreated(address indexed tokenAddress, address indexed creator);

    function createNewToken(string calldata name, string calldata symbol, uint256 supply, string calldata logoURL) external {
        DSystemToken newToken = new DSystemToken(name, symbol, supply, msg.sender, logoURL);
        allTokens.push(address(newToken));
        emit TokenCreated(address(newToken), msg.sender);
    }
}