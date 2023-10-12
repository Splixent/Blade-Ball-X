local Shared = game:GetService("ReplicatedStorage").Shared

local SharedTypes

export type Replica = {
    Children: any,
    Class: string,
    Data: any,
    Id: number,
    Tags: any,
    _creation_data: any,
    _maid: any,
    _pending_replication: any,
    _replication: { Player: Player },
    _signal_listeners: any,
 }

export type Signal = any

return nil