// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity 0.6.12;

abstract contract OwnerRole {
    address public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor () public {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


pragma solidity 0.6.12;

abstract contract MinterRole {
    mapping(address => bool) private minters;

    event MinterAdded(address indexed _minter);
    event MinterRemoved(address indexed _minter);

    constructor () public {
        addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(minters[msg.sender], "Minterable: caller is not the minter");
        _;
    }

    function isIMinter() external view returns (bool) {
        return minters[msg.sender];
    }

    function isMinter(address _minter) external view virtual returns (bool) {
        return minters[_minter];
    }

    function addMinter(address _minter) public virtual {
        minters[_minter] = true;
        emit MinterAdded(_minter);
    }

    function removeMinter(address _minter) public virtual {
        minters[_minter] = false;
        emit MinterRemoved(_minter);
    }
}


pragma solidity 0.6.12;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}


pragma solidity 0.6.12;

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

    function burn(uint256 _amount) external virtual {
        _burn(msg.sender, _amount);
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


pragma solidity 0.6.12;

contract Token is BEP20 {
    constructor(string memory _name, string memory _symbol, uint256 _initialSupply) public BEP20(_name, _symbol) {
        _mint(msg.sender, _initialSupply * 10 ** uint256(decimals));
    }
}

pragma solidity 0.6.12;

contract MasterChef is OwnerRole {
    using SafeMath for uint256;

    Token public token;

    uint256 public tokensPerBlock;
    uint256 public startBlock;
    uint256 public totalAllocPoint;

    address public devAddress;
    uint16 public harvestDevFee;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint16 extraBonus;
    }

    struct PoolInfo {
        IBEP20 token;
        uint256 total;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accTokensPerShare;
        uint16 depositFee;
        uint16 withdrawFee;
        uint16 extraBonus;
    }

    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(Token _token, uint256 _tokensPerBlock, uint256 _startBlock) public {
        token = _token;
        tokensPerBlock = _tokensPerBlock;
        startBlock = _startBlock;

        devAddress = msg.sender;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function getMultiplier(uint256 _blockFrom, uint256 _blockTo) public pure returns (uint256) {
        return _blockTo.sub(_blockFrom);
    }

    function calcFee(uint256 _amount, uint16 _percent) public pure returns (uint256) {
        return _amount.mul(_percent).div(10000);
    }

    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }

        if (pool.total == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 tokensReward = multiplier.mul(tokensPerBlock).mul(pool.allocPoint).div(totalAllocPoint);

        if (harvestDevFee > 0) {
            uint256 harvestFeeAmount = calcFee(tokensReward, harvestDevFee);
            token.mint(address(this), harvestFeeAmount);
            token.transfer(devAddress, harvestFeeAmount);
        }

        token.mint(address(this), tokensReward);

        pool.accTokensPerShare = pool.accTokensPerShare.add(tokensReward.mul(1e12).div(pool.total));
        pool.lastRewardBlock = block.number;
    }

    function pending(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        uint256 accTokensPerShare = pool.accTokensPerShare;

        if (block.number > pool.lastRewardBlock && pool.total != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 treeReward = multiplier.mul(tokensPerBlock).mul(pool.allocPoint).div(totalAllocPoint);

            accTokensPerShare = accTokensPerShare.add(treeReward.mul(1e12).div(pool.total));
        }

        uint256 total = user.amount.mul(accTokensPerShare).div(1e12).sub(user.rewardDebt);

        if (user.extraBonus > 0) {
            uint256 extraBonusAmount = calcFee(total, user.extraBonus);
            total = total.add(extraBonusAmount);
        }

        return total;
    }

    function deposit(uint256 _pid, uint256 _amount) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        updatePool(_pid);

        if (user.amount > 0) {
            uint256 pendingTokens = user.amount.mul(pool.accTokensPerShare).div(1e12).sub(user.rewardDebt);
            if (pendingTokens > 0) {
                safeTokenTransfer(msg.sender, pendingTokens, _pid);
            }
        }

        if (_amount > 0) {
            pool.token.transferFrom(address(msg.sender), address(this), _amount);

            if (pool.depositFee > 0) {
                uint256 depositFeeAmount = calcFee(_amount, pool.depositFee);

                pool.token.transfer(devAddress, depositFeeAmount);
                _amount = _amount.sub(depositFeeAmount);
            }

            user.amount = user.amount.add(_amount);
            pool.total = pool.total.add(_amount);

            if (pool.extraBonus > user.extraBonus) {
                user.extraBonus = pool.extraBonus;
            }
        }

        user.rewardDebt = user.amount.mul(pool.accTokensPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount);

        updatePool(_pid);

        if (user.amount > 0) {
            uint256 pendingTokens = user.amount.mul(pool.accTokensPerShare).div(1e12).sub(user.rewardDebt);
            if (pendingTokens > 0) {
                safeTokenTransfer(msg.sender, pendingTokens, _pid);
            }
        }

        if (_amount > 0) {
            user.extraBonus = 0;
            user.amount = user.amount.sub(_amount);
            pool.total = pool.total.sub(_amount);

            if (pool.withdrawFee > 0) {
                uint256 withdrawFeeAmount = calcFee(_amount, pool.withdrawFee);

                pool.token.transfer(devAddress, withdrawFeeAmount);
                _amount = _amount.sub(withdrawFeeAmount);
            }

            pool.token.transfer(address(msg.sender), _amount);
        }

        user.rewardDebt = user.amount.mul(pool.accTokensPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        uint256 amount = user.amount;

        user.amount = 0;
        user.extraBonus = 0;
        user.rewardDebt = 0;

        pool.total = pool.total.sub(amount);

        if (pool.withdrawFee > 0) {
            uint256 withdrawFeeAmount = calcFee(amount, pool.withdrawFee);

            pool.token.transfer(devAddress, withdrawFeeAmount);
            amount = amount.sub(withdrawFeeAmount);
        }

        pool.token.transfer(address(msg.sender), amount);

        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    function safeTokenTransfer(address _to, uint256 _amount, uint256 _pid) internal {
        uint256 balance = token.balanceOf(address(this));
        if (_amount > balance) {
            _amount = balance;
        }

        token.transfer(_to, _amount);

        UserInfo storage user = userInfo[_pid][_to];
        if (user.extraBonus > 0) {
            uint256 extraBonusAmount = calcFee(_amount, user.extraBonus);
            token.mint(address(this), extraBonusAmount);
            token.transfer(_to, extraBonusAmount);
        }
    }

    function add(IBEP20 _token, uint256 _allocPoint, uint16 _depositFee, uint16 _withdrawFee, uint16 _extraBonus, bool _withUpdate) external onlyOwner {
        require(_depositFee >= 0 && _depositFee <= 500);
        require(_withdrawFee >= 0 && _withdrawFee <= 500);

        if (_withUpdate) {
            massUpdatePools();
        }

        totalAllocPoint = totalAllocPoint.add(_allocPoint);

        poolInfo.push(PoolInfo({
            token: _token,
            total: 0,
            allocPoint: _allocPoint,
            lastRewardBlock: block.number > startBlock ? block.number : startBlock,
            accTokensPerShare: 0,
            depositFee: _depositFee,
            withdrawFee: _withdrawFee,
            extraBonus: _extraBonus
        }));
    }

    function set(uint256 _pid, uint256 _allocPoint, uint16 _depositFee, uint16 _withdrawFee, uint16 _extraBonus, bool _withUpdate) external onlyOwner {
        require(_depositFee >= 0 && _depositFee <= 500);
        require(_withdrawFee >= 0 && _withdrawFee <= 500);

        if (_withUpdate) {
            massUpdatePools();
        }

        uint256 prevAllocPoint = poolInfo[_pid].allocPoint;

        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].depositFee = _depositFee;
        poolInfo[_pid].withdrawFee = _withdrawFee;
        poolInfo[_pid].extraBonus = _extraBonus;

        if (prevAllocPoint != _allocPoint) {
            totalAllocPoint = totalAllocPoint.sub(prevAllocPoint).add(_allocPoint);
        }
    }

    function updateExtraBonus(uint16 _extraBonus) external onlyOwner {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            poolInfo[pid].extraBonus = _extraBonus;
        }
    }

    function updateDevAddress(address _devAddress) external onlyOwner {
        devAddress = _devAddress;
    }

    function updateHarvestDevFee(uint16 _harvestDevFee) external onlyOwner {
        harvestDevFee = _harvestDevFee;
    }

    function updateTokensPerBlock(uint256 _tokensPerBlock) external onlyOwner {
        massUpdatePools();
        tokensPerBlock = _tokensPerBlock;
    }
}
