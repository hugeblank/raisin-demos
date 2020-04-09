-- groupdemo.lua by hugeblank
-- This program is for a demonstration of Raisin, a program by hugeblank. Found at: https://github.com/hugeblank/raisin
-- You are free to add, remove, and distribute from this program as you wish as long as these first three lines are kept in tact

local raisin = require("raisin").manager(os.pullEvent) -- load Raisin

--[[ GROUP THREADING DEMONSTRATION
    Our objective will be to make 3 threads among 2 groups.
    The first thread will be a generic thread that counts the seconds the program has been executing.
    The second thread will be an input thread that will be used to toggle the second group.
    The third thread will be a simple animated spinner, in group two.
    All but the third thread will be in the first group. 
    The master group (id 0) will not be used in this demonstration, but it could easily be adapted to do so.
    Let's begin!
]]

local grp1 = raisin.group(1) -- We create the two groups for the threads
local grp2 = raisin.group(2)

--[[ A NOTE ON PRIORITIES
    It's worth taking into consideration the power of selecting the priorities of threads and groups. 
    In this example the priorities aren't necessarily too important, but I have the ability to manually select which thread goes first, no matter which order I add them.
    This same thing happens in the parallel API, however it's the order in which you place the functions in the arguments of waitForAny/All.
    Personally I think that explicitly being able to set the priority of execution per thread makes a bit more sense, and decreases the confusion of what goes first.
]]


raisin.thread(function() -- Let's start with the spinner in group 2. It's the easiest
    print("this thread is in group 2") -- Let's mention that we have a thread in group 2.
    sleep()
    local x, y = 1, 5 -- Setting some arbitrary coordinates for the spinner, just for the sake of the demo.
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
end, 0, grp2) -- We set the priority to 0, in this case it doesn't matter. Then we set the group that this thread is a member of.

raisin.thread(function() -- Now let's add the input thread with our toggling
    print('this thread is in group 1, a') -- Mentioning that this thread is the first thread in group 1 (as denoted by it's priority being 0, and the following thread being 1)
    sleep() -- Allowing all other threads to spit out their activation statements before going into our own routine
    local x, y = 1, 4 -- Setting more arbitrary coorinates
    while true do -- Begin the thread
        term.setCursorPos(x, y) -- Set the cursor to the right position
        term.clearLine() -- Clear the line
        local res
        if grp2.state() == true then -- If the second group is enabled
            print("type 'stop' to stop group 2") -- Output the stop text
        else -- OTHERWISE
            print("type 'start' to start group 2") -- Output the start text
        end
        term.setCursorPos(x+1, y+1) -- Set the cursor position again so that it's next to the spinner
        term.setCursorBlink(true) -- Taking care of minor glitch with cursor
        res = read() -- Get the input
        term.setCursorBlink(false)
        if res:lower() == "start" or res:lower() == "stop" then -- If the text is 'start' or 'stop'
            grp2.toggle() -- toggle the group
            sleep() -- yeild to allow activation of the group in the event that it's being enabled
        end
        paintutils.drawLine(x+1, y+1, x+5, y+1, colors.black) -- Clear the text being read
    end
end, 0, grp1) -- This thread is set to priority 0, like the one in group 2, but since group 1 has a higher priority than group 2, this thread gets executed first. 

raisin.thread(function() -- The final thread we'll add in this demonstration is the counter thread which we'll add to group 1. 
    print("this thread is in group 1, b") -- Mention that this thread has been added, and it's the second thread of group 1
    sleep()
    local a = 0 -- Set the counter variable
    while true do -- Begin the thread
        local oc = {term.getCursorPos()}
        term.setCursorPos(1, 6) -- Set the cursor position to another arbitrary value
        print(a) -- Print the counter value 
        a = a+1 -- Add one to it
        term.setCursorPos(table.unpack(oc))
        sleep(1) -- yield
    end
end, 1, grp1)


term.clear() -- Clear the screen
term.setCursorPos(1, 1) -- Set the cursor position to the origin
raisin.run() -- Execute the threads

--[[ ADDITIONAL ACTIVITIES
    Add a thread to the master group that after enables and disables the first group. You could do this one a number of ways.
    Add another thread to group 2 to grasp the effects of pausing the execution of a thread.
]]