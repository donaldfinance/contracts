// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "./roles/OwnerRole.sol";
import "./roles/MinterRole.sol";
import "./SafeMath.sol";

abstract contract BEP20 is OwnerRole, MinterRole {
    using SafeMath for uint256;

    uint256 public totalSupply;
    uint256 public totalBurned;

    string public name;
    string public symbol;
    uint8 public decimals = 18;

    uint16 public burnFee;
    uint16 public devFee;

    mapping(address => uint256) private balances;

    mapping(address => mapping(address => uint256)) private allowances;

    constructor(string memory _name, string memory _symbol) public {
        name = _name;
        symbol = _symbol;
    }

    function balanceOf(address _account) external view virtual returns (uint256) {
        return balances[_account];
    }

    function allowance(address _from, address _to) external view virtual returns (uint256) {
        return allowances[_from][_to];
    }

    function mint(address _to, uint256 _amount) external virtual onlyMinter {
        _mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) external virtual onlyOwner {
        _burn(_from, _amount);
    }

    function approve(address _to, uint256 _amount) external virtual returns (bool) {
        require(_amount > 0, "BEP20: amount must be greater than zero");

        _approve(msg.sender, _to, _amount);
        return true;
    }

    function transfer(address _to, uint256 _amount) external virtual returns (bool) {
        require(msg.sender != _to, "BEP20: can't transfer to own address");

        _transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) external virtual returns (bool) {
        require(_from != _to, "BEP20: can't transfer to own address");
        require(allowances[_from][msg.sender] >= _amount, "BEP20: transfer amount exceeds allowance");

        _transfer(_from, _to, _amount);
        _approve(_from, msg.sender, allowances[_from][msg.sender] - _amount);

        return true;
    }

    function increaseAllowance(address _to, uint256 _amount) external virtual returns (bool) {
        require(_amount > 0, "BEP20: amount must be greater than zero");

        uint256 total = allowances[msg.sender][_to].add(_amount);
        _approve(msg.sender, _to, total);
        return true;
    }

    function decreaseAllowance(address _to, uint256 _amount) external virtual returns (bool) {
        require(allowances[msg.sender][_to] >= _amount, "BEP20: decreased allowance below zero");
        require(_amount > 0, "BEP20: amount must be greater than zero");

        uint256 total = allowances[msg.sender][_to].sub(_amount);
        _approve(msg.sender, _to, total);
        return true;
    }

    function addMinter(address _minter) public onlyOwner override(MinterRole) {
        super.addMinter(_minter);
    }

    function removeMinter(address _minter) public onlyOwner override(MinterRole) {
        super.removeMinter(_minter);
    }

    function updateBurnFee(uint16 _percent) external onlyOwner {
        require(_percent >= 0 && _percent <= 10000, "BEP20: incorrect percentage");
        require(_percent + devFee <= 10000, "BEP20: the sum of all commissions cannot exceed 10000 percent");

        burnFee = _percent;
    }

    function updateDevFee(uint16 _percent) external onlyOwner {
        require(_percent >= 0 && _percent <= 10000, "BEP20: incorrect percentage");
        require(_percent + burnFee <= 10000, "BEP20: the sum of all commissions cannot exceed 10000 percent");

        devFee = _percent;
    }

    function calcFee(uint256 _amount, uint16 _percent) public pure returns (uint256) {
        require(_percent >= 0 && _percent <= 10000, "BEP20: incorrect percentage");

        return _amount.mul(_percent).div(10000);
    }

    function _mint(address _to, uint256 _amount) internal virtual {
        require(_to != address(0), "BEP20: mint to the zero address");
        require(_amount > 0, "BEP20: amount must be greater than zero");

        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);

        emit Transfer(address(0), _to, _amount);
    }

    function _burn(address _from, uint256 _amount) internal virtual {
        require(_from != address(0), "BEP20: burn from the zero address");
        require(_amount > 0, "BEP20: amount must be greater than zero");
        require(balances[_from] >= _amount, "BEP20: burn amount exceeds balance");

        balances[_from] = balances[_from].sub(_amount);
        totalSupply = totalSupply.sub(_amount);
        totalBurned = totalBurned.add(_amount);

        emit Transfer(_from, address(0), _amount);
    }

    function _approve(address _from, address _to, uint256 _amount) internal virtual {
        require(_from != address(0), "BEP20: approve from the zero address");
        require(_to != address(0), "BEP20: approve to the zero address");

        allowances[_from][_to] = _amount;
        emit Approval(_from, _to, _amount);
    }

    function _transfer(address _from, address _to, uint256 _amount) internal virtual {
        require(_from != address(0), "BEP20: transfer from the zero address");
        require(_to != address(0), "BEP20: transfer to the zero address");
        require(balances[_from] >= _amount, "BEP20: transfer amount exceeds balance");
        require(_amount > 0, "BEP20: amount must be greater than zero");

        uint256 burnFeeValue = calcFee(_amount, burnFee);
        uint256 devFeeValue = calcFee(_amount, devFee);
        uint256 calculatedAmount = _amount.sub(burnFeeValue).sub(devFeeValue);

        balances[_from] = balances[_from].sub(calculatedAmount).sub(devFeeValue);

        if (calculatedAmount > 0) {
            balances[_to] = balances[_to].add(calculatedAmount);
            emit Transfer(_from, _to, calculatedAmount);
        }

        if (devFeeValue > 0) {
            balances[owner] = balances[owner].add(devFeeValue);
            emit Transfer(_from, owner, devFeeValue);
        }

        if (burnFeeValue > 0) {
            _burn(_from, burnFeeValue);
        }
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
