local jid_split = require "util.jid".split;

module:hook('muc-set-affiliation', function(event)
        if jid_split(event.jid) ~= 'focus' and event.affiliation == 'owner' then
                module:log("info", "creating room for event %s", event.jid);
                prosody.events.fire_event("create-lobby-room", { room = event.room; });
        end
end);
