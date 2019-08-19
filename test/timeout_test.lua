local helper = require('test.helper')
local netbox = require('net.box')
local fiber = require('fiber')

local t = require('luatest')

local g = t.group('timeout_test')

--

g.before_all = function()
    queue_conn = netbox.connect('localhost:3301')
end

g.after_all = function()
    queue_conn:close()
end

--

local function task_take(tube, timeout, channel)
    -- fiber function for take task with timeout and calc duration time
    local start = fiber.time64()
    local task = queue_conn:call('tube:take', { timeout })
    local duration = fiber.time64() - start
    
    channel:put(duration)
    channel:put(task)

    fiber.kill(fiber.id())
end
--

function g.test_try_waiting()
    -- TAKE task with timeout
    -- CHECK uptime and value - nil

    local tube_name = 'try_waiting_test'
    queue_conn:eval('tube = shared_queue.create_tube(...)', { tube_name })

    local timeout = 3 -- second

    local channel = fiber.channel(2)
    local task_fiber = fiber.create(task_take, tube, timeout, channel)

    fiber.sleep(timeout)

    local waiting_time = tonumber(channel:get()) / 1e6
    local task = channel:get()

    t.assert_equals(helper.round(waiting_time, 0.1), 3)
    t.assert_equals(task, nil)

    channel:close()
end
--

function g.test_wait_put_taking()
    -- TAKE task with timeout
    -- WAIT timeout value / 2
    -- PUT task to tube
    -- CHEK what was taken successfully

    local tube_name = 'wait_put_taking_test'
    queue_conn:eval('tube = shared_queue.create_tube(...)', { tube_name })
    local timeout = 3

    local channel = fiber.channel(2)
    local task_fiber = fiber.create(task_take, tube, timeout, channel)

    fiber.sleep(timeout / 2)
    queue_conn:call('tube:put', { 'simple_task' })

    local waiting_time = tonumber(channel:get()) / 1e6
    local task = channel:get()

    t.assert_equals(helper.round(waiting_time, 0.1), timeout / 2)
    t.assert_equals(task[helper.index.data], 'simple_task')

    channel:close()
end