pragma solidity ^0.5.7;

contract vendor {
    // contract owner
    address payable private creator;

    // IoT device data
    struct device_data {
        // link for detecting devices
        uint index;
        // blockchain timestamps stored swarm hashes
        uint[] timestamps;
        // map timestamp values to swarm file hashes
        mapping(uint => uint) data;
        uint consumption;
        uint bill;
    }

    // map device id's to their data (one data per id)
    mapping(bytes32 => device_data) private device_logs;
    //owner addresses
    mapping(address => bytes32[]) private device_owners;
    // keep a separate device id array of all received id's
    bytes32[] private device_index;
    // event to log action
    event log_action (bytes32 indexed device_id, uint index, uint timestamp, uint data);

    uint energy_cost = 1 wei;

    // check if device is seen before?
    // https://medium.com/@robhitchens/solidity-crud-part-1-824ffa69509a
    function is_device_present (bytes32 device_id) public view returns (bool result) {
        // return false if no device present yet!
        if(device_index.length == 0) return false;
        // return true if device exists
        return (device_index[device_logs[device_id].index] == device_id);
    }

    // push specific device data handle into the chain
    function set_device_data (bytes32 device_id, uint data) public returns (uint index, uint timestamp) {
        uint ts;
        if(is_device_present(device_id)) {
            // device already exists
            ts = now;
            if( device_logs[device_id].timestamps.length == 0 ||
                device_logs[device_id].timestamps[device_logs[device_id].timestamps.length-1] < ts) {
                // first insertion or insertion made (at least) in last block
                device_logs[device_id].timestamps.push(ts);
                device_logs[device_id].data[ts] = data;
                device_logs[device_id].consumption += data;
                device_logs[device_id].bill += energy_cost * data;
            } else {
                // doc, this is heavy!
                assert(false);
            }
            // trigger event
            emit log_action(device_id, device_logs[device_id].index, ts, data);
            return(device_logs[device_id].index, ts);
        } else {
            // device received first time
            ts = now;
            device_logs[device_id].timestamps.push(ts);
            device_logs[device_id].data[ts] = data;
            device_logs[device_id].index = device_index.push(device_id)-1;
            // trigger event
            emit log_action(device_id, device_index.length-1, ts, data);
            device_logs[device_id].consumption += data;
            device_logs[device_id].bill += energy_cost * data;
            device_owners[msg.sender].push(device_id);
            return(device_index.length-1, ts);
        }
    }

    // get received data at a certain timestamp for a specific device
    function get_device_data (bytes32 device_id, uint timestamp) public view returns (uint data) {
        if(!is_device_present(device_id)) revert();
        return device_logs[device_id].data[timestamp];
    }


    //get device consumption by device_id
    function get_device_consumption(bytes32 device_id) public view returns (uint data) {
        if(!is_device_present(device_id)) revert();
        return device_logs[device_id].consumption;
    }

    //used by contract owner to change the energy cost(wei)
    function set_energy_cost(uint cost) public returns (uint data){
        if (msg.sender != creator) revert();
        energy_cost = cost;
        return energy_cost;
    }

    //returns current energy cost per kw
   function get_energy_cost() public view returns (uint data){
        return energy_cost;
    }

    //returns energy cost bill for device
    function get_device_bill(bytes32 device_id) public view returns (uint data){
        return device_logs[device_id].bill;
    }

    //returns registered device ids for msg sender
    function get_owned_devices() public view returns (bytes32[] memory device_ids){
        return device_owners[msg.sender];
    }

    //pays the bill for the device.
    function pay_device_data(bytes32 device_id) public payable returns (uint data){
        if (msg.value > get_device_bill(device_id)) revert();
        device_logs[device_id].bill -= msg.value;
        return device_logs[device_id].bill;
    }

    // get all data timestamps for a specific device
    function get_device_timestamps (bytes32 device_id) public view returns (uint[] memory timestamp) {
        if(!is_device_present(device_id)) revert();
        return device_logs[device_id].timestamps;
    }

    // get total device count
    function get_device_count() public view returns (uint count) {
        return device_index.length;
    }

    // get device address from index
    function get_device_at_index (uint index) public view returns (bytes32 device_id) {
        return device_index[index];
    }

    // constructor
    constructor(uint cost) public{
        creator = msg.sender;
        energy_cost = cost;
    }

    // kills contract and sends remaining funds back to creator
    function kill() public {
        if (msg.sender == creator) {
            selfdestruct(creator);
        }
    }
}
