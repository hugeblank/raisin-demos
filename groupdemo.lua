-- groupdemo.lua by hugeblank
-- This program is for a demonstration of Raisin, a program by hugeblank. Found at: https://github.com/hugeblank/raisin
-- You are free to add, remove, and distribute from this program as you wish as long as these first three lines are kept in tact

local raisin = require("raisin.raisin") -- load Raisin
--local thread = raisin.thread -- Thread library isn't used in this demo, all we're using are groups
local group = raisin.group -- Make the group API easier to use, you may or may not want to do this

--[[ GROUP THREADING DEMONSTRATION
    Our objective will be to make 3 threads among 2 groups.
    The first thread will be a generic thread that counts the seconds the program has been executing.
    The second thread will be an input thread that will be used to toggle the second group.
    The third thread will be a simple animated spinner, in group two.
    All but the third thread will be in the first group. 
    The master group (id 0) will not be used in this demonstration, but it could easily be adapted to do so.
    Let's begin!
]]

local grp1 = group.wrap(group.add(1)) -- Method 1 of creating a group: adding then immediately wrapping it
local g2id = group.add(2) -- Method 2 of creating a group: adding it and using the group ID in the thread library as the third argument to functions that take in a group parameter
local grp2 = group.wrap(g2id) -- For this example I'll be sticking to wrapping it, but we do still need the ID for the group to be able to toggle it

--[[ A NOTE ON PRIORITIES
    It's worth taking into consideration the power of selecting the priorities of threads and groups. 
    In this example the priorities aren't necessarily too important, but I have the ability to manually select which thread goes first, no matter which order I add them.
    This same thing happens in the parallel API, however it's the order in which you place the functions in the arguments of waitForAny/All.
    Personally I think that explicitly being able to set the priority of execution per thread makes a bit more sense, and decreases the confusion of what goes first.
]]


grp2.add(function() -- Let's start with the spinner in group 2. It's the easiest
    print("this thread is in group 2") -- Let's mention that we have a thread in group 2.
    local x, y = 30, 10 -- Setting some arbitrary coordinates for the spinner, just for the sake of the demo.
    while true do -- Begin thread
        term.setCursorPos(x, y) -- Set the cursor position to the coordinates, since we won't know where the cursor will be
        term.write("|") -- Write the animation
        sleep(.1) -- Pause execution
        term.setCursorPos(x, y) -- next animation
        term.write("/")
        sleep(.1)
        term.setCursorPos(x, y) -- and the next
        term.write("-")
        sleep(.1)
        term.setCursorPos(x, y) -- and the next
        term.write("\\")
        sleep(.1)
    end
end, 0) -- We set the priority to 0, but in this case it doesn't matter.

grp1.add(function() -- Now let's add the input thread with our toggling
    print('this thread is in group 1, a') -- Mentioning that this thread is the first thread in group 1 (as denoted by it's priority being 0, and the following thread being 1)
    local x, y = 30, 9 -- Setting more arbitrary coorinates
    sleep() -- Allowing all other threads to spit out their activation statements before going into our own routine
    while true do -- Begin the thread
        if group.state(g2id) == true then -- If the second group is enabled
            term.setCursorPos(x, y) -- Set the cursor to the right position
            term.clearLine() -- Clear the line
            print("type stop to stop group 2") -- Output the stop text
            term.setCursorPos(x+1, y) -- Set the cursor postion so that it's next to the spinner
            -- The line above is really odd, even if you set the y value to something really far away, the read function jumps back next to the spinner. The entire thread had to be written around this issue.
            -- If you have any clue what's going wrong I'd love some input on it. This issue is unrelated to Raisin, so the demo can continue.
            local res = read() -- Get the input
            if res:lower() == "stop" then -- If the text is 'stop'
                group.toggle(g2id) -- toggle the group
            end
        else -- OTHERWISE
            term.setCursorPos(x, y) -- set the cursor position
            term.clearLine() -- Clear the line
            print("type start to start group 2") -- Output the start text
            term.setCursorPos(x+1, y+1) -- Set the cursor position abain so that it's next to the spinner
            local res = read() -- Get the input
            if res:lower() == "start" then -- If the text is 'start'
                group.toggle(g2id) -- toggle the group
            end
        end
        paintutils.drawLine(x+1, y+1, x+5, y+1, colors.black) -- Clear the text being read
    end
end, 0) -- This thread is set to priority 0, like the one in group 2, but since group 1 has a higher priority than group 2, this thread gets executed first. 

grp1.add(function() -- The final thread we'll add in this demonstration is the counter thread which we'll add to group 1. 
    print("this thread is in group 1, b") -- Mention that this thread has been added, and it's the second thread of group 1
    local a = 0 -- Set the counter variable
    while true do -- Begin the thread
        term.setCursorPos(30, 11) -- Set the cursor position to another arbitrary value
        print(a) -- Print the counter value 
        a = a+1 -- Add one to it
        sleep(1) -- yield
    end
end, 1)


term.clear() -- Clear the screen
term.setCursorPos(1, 1) -- Set the cursor position to the origin
raisin.manager.run() -- Execute the threads

--[[ ADDITIONAL ACTIVITIES
    Add a thread to the master group that after enables and disables the first group. You could do this one a number of ways.
    Add another thread to group 2 to grasp the effects of pausing the execution of a thread.
]]
