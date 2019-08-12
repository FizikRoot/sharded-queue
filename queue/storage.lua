local cluster = require('cluster')
local checks = require('checks')
local log = require('log')

local queue_driver = require('queue.driver_fifottl')

local function apply_config(cfg, opts)
    if opts.is_master then
        for _, t in pairs(cfg.tubes or {}) do
            queue_driver.create(t)
        end
    end
    return true
end

local function init(opts)
    if opts.is_master then
        --
        box.schema.user.grant('guest',
            'read,write',
            'universe',
            nil, { if_not_exists = true })
        --
        rawset(_G, 'tube_put', queue_driver.put)
        box.schema.func.create('tube_put')
        box.schema.user.grant('guest', 'execute', 'function', 'tube_put')
        
        rawset(_G, 'tube_take', queue_driver.take)
        box.schema.func.create('tube_take')
        box.schema.user.grant('guest', 'execute', 'function', 'tube_take')
        
        rawset(_G, 'tube_delete', queue_driver.delete)
        box.schema.func.create('tube_delete')
        box.schema.user.grant('guest', 'execute', 'function', 'tube_delete')
        
        rawset(_G, 'tube_release', queue_driver.release)
        box.schema.func.create('tube_release')
        box.schema.user.grant('guest', 'execute', 'function', 'tube_release')
        --
    end
end

return {
    init = init,
    apply_config = apply_config,
    dependencies = {
        'cluster.roles.vshard-storage',
    },
}
