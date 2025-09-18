local cfg = require("@pierrelasse/plugins/admincommands/_cfg")


events.onStarted(function()
    for i in forEach(cfg.modules) do
        require("@pierrelasse/plugins/admincommands/"..i)
    end
end)
