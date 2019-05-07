-- threaddemo.lua by hugeblank
-- This program is for a demonstration of Raisin, a program by hugeblank. Found at: https://github.com/hugeblank/raisin
-- You are free to add, remove, and distribute from this program as you wish as long as these first three lines are kept in tact

local raisin = require("raisin.raisin") -- Load Raisin

--[[ GENERIC RAISIN THREAD DEMONSTRATION
    Our objective will be to make 2 threads with different priorities
    The first thread will be a generic thread that counts the seconds.
    The second thread will stop the first thread every five seconds, and wait for a mouse click to continue counting.

    The master group will be used in this demonstration. By default when a group number is not provided to thread.add, it goes into the master group.
    This allows for simple programs to be created in just a few lines without the need for creating a group. All this mention of groups may be going over your head. 
    I suggest after this demonstration you look at my groupdemo.lua file. 

    TL;DR the thread library is an easy access point for multithreading without getting into the raisin 'group' kerfuffle
    Let's begin!
]]

local a, clicked = 1, false -- Create a basic counting value

-- We start by creating the counter, since we'll need it's ID later on to toggle it.
local slave = raisin.thread(function() -- Create a new thread.
    while true do
        print(a)
        sleep(1)
        a = a+1
        clicked = false
    end
end, 0) -- Set the priority of this thread to 0. This way on starting the program this thread goes first before the one below. 
-- If we let the one below go first, we'd have to click the first time the program starts. 

-- Now let's create the thread stopper
raisin.thread(function() -- Create another new thread
    while true do -- Begin thread
        if a%5 == 0 and not clicked then
            print("pausing thread...") -- Notify the user that the thread is being paused
            slave.toggle(id) -- Toggle the slave thread above
            print("click anywhere to continue counting") -- Notify the user that they need to click to re-enable the slave
            os.pullEvent("mouse_click") -- pull that mouse click event
            clicked = true
            print('continuing...') -- Notify the user we're continuing execution
            slave.toggle(id) -- Toggle the thread again to enable it
        end
        sleep() -- Yield for a second
    end
end, 1) -- Set the priority of this thread to something lower than the first one. 
-- We could set this thread to priority 0 and it would still execute after the thread above. Threads follow priority order, but if 2 threads share the same priority they go in the order that they were written.

--[[thread.add(function() -- Mysterious Function for Additional Activities
    print("> exiting in")
    for i = 3, 1, -1 do
        print("> "..i)
        sleep(1)
    end
end, 2)]]

raisin.manager.run() -- Signal to start execution

--[[ADDITIONAL ACTIVITIES
    Replace the mouse click thread with something that requires you to type in a specific word, or do a specific combination of actions
    Tamper around with the `raisin.manager.run()` above. The first parameter it takes in is the amount of threads that need to be dead in order for it to exit. See what effect that mystery function has on the execution of the program
]]