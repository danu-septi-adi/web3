// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract DSystemToken {
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    string public tokenLogoURL;
    address public owner;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory _name, string memory _symbol, uint256 _supply, address _owner, string memory _logo) {
        name = _name;
        symbol = _symbol;
        tokenLogoURL = _logo;
        owner = _owner;
        unchecked {
            totalSupply = _supply * 10**18;
        }
        balanceOf[_owner] = totalSupply;
        emit Transfer(address(0), _owner, totalSupply);
    }

    // Fungsi transfer paling hemat gas
    function transfer(address to, uint256 value) external returns (bool) {
        require(balanceOf[msg.sender] >= value, "Low Balance");
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

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(balanceOf[from] >= value, "Low Balance");
        require(allowance[from][msg.sender] >= value, "Low Allowance");
        unchecked {
            balanceOf[from] -= value;
            balanceOf[to] += value;
            allowance[from][msg.sender] -= value;
        }
        emit Transfer(from, to, value);
        return true;
    }

    function updateMetadata(string calldata _newName, string calldata _newSymbol, string calldata _newLogo) external {
        require(msg.sender == owner, "Owner Only");
        name = _newName;
        symbol = _newSymbol;
        tokenLogoURL = _newLogo;
    }
}

contract TokenFactory {
    event TokenCreated(address indexed tokenAddress, address indexed creator);

    function createNewToken(string calldata name, string calldata symbol, uint256 supply, string calldata logoURL) external {
        DSystemToken newToken = new DSystemToken(name, symbol, supply, msg.sender, logoURL);
        emit TokenCreated(address(newToken), msg.sender);
    }
}