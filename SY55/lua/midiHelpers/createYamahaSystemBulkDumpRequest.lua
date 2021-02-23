function createYamahaSystemBulkDumpRequest(channel)
    console("createYamahaSystemBulkDumpRequest" .. channel)
	-- Your method code here
  return createYamahaBulkDumpRequest(channel,'LM  8103SY',0,0)
end