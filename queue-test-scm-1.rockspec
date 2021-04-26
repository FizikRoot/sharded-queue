package = 'queue-test'
version = 'scm-1'
source  = {
    url = '/dev/null',
}
-- Put any modules your app depends on here
dependencies = {
    'tarantool',
    'lua >= 5.1',
    'checks == 3.1.0-1',
    'cartridge == 2.5.1-1',
    'metrics == 0.7.1-1',
    'cartridge-cli-extensions == 1.1.1-1',
    'expirationd',
    'vshard',
}
build = {
    type = 'make',
	build_target = 'all',
    install = {
        lua = {
            ['sharded_queue.api'] = 'sharded_queue/api.lua',
            ['sharded_queue.storage'] = 'sharded_queue/storage.lua',
            ['sharded_queue.drivers.fifo'] = 'sharded_queue/drivers/fifo.lua',
            ['sharded_queue.drivers.fifottl'] = 'sharded_queue/drivers/fifottl.lua',
            ['sharded_queue.time'] = 'sharded_queue/time.lua',
            ['sharded_queue.utils'] = 'sharded_queue/utils.lua',
            ['sharded_queue.state'] = 'sharded_queue/state.lua',
            ['sharded_queue.statistics'] = 'sharded_queue/statistics.lua',
        },
    },
    build_variables = {
        version = 'scm-1',
    },
    install_pass = false,
}
