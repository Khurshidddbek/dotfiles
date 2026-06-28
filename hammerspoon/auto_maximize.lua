hs.window.animationDuration = 0

local function maximize(win)
    if not win then return end

    -- Skip popups, dialogs, panels, sheets — only maximize standard app windows
    if win:subrole() ~= "AXStandardWindow" then return end

    local screen = win:screen()
    if not screen then return end

    win:setFrame(screen:frame())
end

hs.window.filter.default:subscribe(
    hs.window.filter.windowCreated,
    function(win)
        maximize(win)
    end
)
