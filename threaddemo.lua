-- threaddemo.lua by hugeblank
-- This program is for a demonstration of Raisin, a program by hugeblank. Found at: https://github.com/hugeblank/raisin
-- You are free to add, remove, and distribute from this program as you wish as long as these first three lines are kept in tact

local raisin = require("raisin").manager(os.pullEvent) -- Load Raisin

--[[ GENERIC RAISIN THREAD DEMONSTRATION
    Our objective will be to make 2 threads with different priorities
    The first thread will be a generic thread that counts the seconds and stops itself every 5 seconds.
    The second thread will wait for a mouse click to resume the first thread and continue counting.

    Let's begin!
]]

local a = 1 -- Create a basic counting value
local slave -- Define variable for slave thread to occupy


-- Now let's start with the click listener
raisin.thread(function() -- Create master thread
    print("Master thread running") -- Verify that this is the second thread executed
    while true do
        if not slave.state() then -- If the thread is disabled
            print("click anywhere to continue counting") -- Notify the user that they need to click to re-enable the slave
            os.pullEvent("mouse_click") -- pull that mouse click event
            print('continuing...') -- Notify the user we're continuing execution
            slave.toggle() -- Toggle the thread again to enable it
        end
        sleep(1) -- Yield for a second
    end
end, 1) -- Set the priority of this thread to something lower than the first one
-- This thread executes second because its priority is going to be larger than the slave thread
-- We test this with the first print statement in the function

slave = raisin.thread(function() -- Create slave thread.
    print("Slave thread running") -- Verify this is the first thread executed
    while true do
        print(a) -- Print count
        if a%5 == 0 then -- If we reach a multiple of 5
            print("pausing thread...") -- Notify the user that the thread is being paused
            slave.toggle() -- And then pause execution on this thread
        end
        a = a+1 -- Increment
        sleep(1)
    end
end, 0) -- Set the priority of this thread to 0. This way on starting the program this thread goes first before the one below.
-- This thread executes first since its priority is 0.
-- We test this in the same way as the master thread

--[[raisin.thread(function() -- Mysterious Function for Additional Activities
    print("> exiting in")
    for i = 3, 1, -1 do
        print("> "..i)
        sleep(1)
    end
    -- How could we get this thread to stop execution?
end, 2)]]

raisin.run(raisin.onDeath.waitForAll()) -- Signal to start execution

--[[ADDITIONAL ACTIVITIES
    Replace the mouse click thread with something that requires you to type in a specific word, or do a specific combination of actions
    Tamper around with the `raisin.manager.run()` above. The first parameter it takes in is the amount of threads that need to be dead in order for it to exit. See what effect that mystery function has on the execution of the program
]]