function streamSum(midi)
    local sum = 0
    console("streamSum: "..midi)
    console(type(midi).. " of size " .. #midi)
    local i
    for i = 1, #midi
    do
       local c = string.byte(midi,i)
       sum = sum + c
    end
    console("Checksum = " .. tostring(sum) .. " % 0x80 = " .. tostring(sum % 0x80))
    return sum
end 