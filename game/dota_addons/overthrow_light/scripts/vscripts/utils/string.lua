-- Utility for string
function string:startsWith(start)
    return string.sub(self, 1, string.len(start)) == start
end

function string:split(sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(self, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

function string:contains(search)
    return string.find(self, search, 1, true) ~= nil
 end