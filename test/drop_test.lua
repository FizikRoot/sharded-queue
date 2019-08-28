local t = require('luatest')
local g = t.group('drop_test')

local config = require('test.helper.config')

g.before_all = function()
    g.queue_conn = config.cluster:server('queue-router').net_box
end

local function shape_cmd(tube_name, cmd)
    return string.format('shared_queue.tube.%s:%s', tube_name, cmd)
end

function g.test_drop_empty()
    local tube_name = 'drop_empty_test'
    
    g.queue_conn:call('shared_queue.create_tube', {
        tube_name
    })
    g.queue_conn:call(shape_cmd(tube_name, 'drop'))

    cur_stat = g.queue_conn:call('shared_queue.statistics', { tube_name })
    t.assert_equals(cur_stat, nil)
end