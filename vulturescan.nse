

local stdnse = require("stdnse")
local have_stringaux, stringaux = pcall(require, "stringaux")
local strsplit = (have_stringaux and stringaux or stdnse).strsplit

portrule = function(host, port)
	if port.version.product ~= nil and port.version.product ~= "" then
		return true
	else
		stdnse.print_debug(1, "vulturescan: No version detection data available. Analysis not possible.")
	endv
end

action = function(host, port)
	local prod = port.version.product	-- product name
	local ver = port.version.version	-- product version
	local struct = "[{id}] {title}\n"	-- default report structure
	local db = {}				-- vulnerability database
	local db_link = ""			-- custom link for vulnerability databases
	local vul = {}				-- details for the vulnerability
	local v_count = 0			-- counter for the vulnerabilities
	local s = ""				-- the output string

	stdnse.print_debug(1, "vulturescan: Found service " .. prod)

	-- Go into interactive mode
	if nmap.registry.args.vulturescan_i == "1" then
		stdnse.print_debug(1, "vulturescan: Enabling interactive mode ...")
		print("The scan has determined the following product:")
		print(prod)
		print("Press Enter to accept. Define new string to override.")
		local prod_override = io.stdin:read'*l'

		if string.len(prod_override) ~= 0 then
			prod = prod_override
			stdnse.print_debug(1, "vulturescan: Product overwritten as " .. prod)
		end
	end

	-- Read custom report structure
	if nmap.registry.args.vulturescanoutput ~= nil then
		if nmap.registry.args.vulturescanoutput == "details" then
			struct = "[{id}] {title}\nMatches: {matches}, Prod: {product}, Ver: {version}\n{link}\n\n"
		elseif nmap.registry.args.vulturescanoutput == "listid" then
			struct = "{id}\n"
		elseif nmap.registry.args.vulturescanoutput == "listlink" then
			struct = "{link}\n"
		elseif nmap.registry.args.vulturescanoutput == "listtitle" then
			struct = "{title}\n"
		else
			struct = nmap.registry.args.vulturescanoutput
		end

		stdnse.print_debug(1, "vulturescan: Custom output structure defined as " .. struct)
	end

	-- Read custom database link
	if nmap.registry.args.vulturescan_dblink ~= nil then
		db_link = nmap.registry.args.vulturescan_dblink
		stdnse.print_debug(1, "vulturescan: Custom database link defined as " .. db_link)
	end

	if nmap.registry.args.vulturescandb then
		stdnse.print_debug(1, "vulturescan: Using single mode db " .. nmap.registry.args.vulturescandb .. " ...")
		vul = find_vulnerabilities(prod, ver, nmap.registry.args.vulturescandb)
		if #vul > 0 then
			s = s .. nmap.registry.args.vulturescandb
			if db_link ~= "" then s = s .. " - " .. db_link end
			s = s .. ":\n" .. prepare_result(vul, struct, db_link) .. "\n\n"
		end
	else
		-- Add your own database, if you want to include it in the multi db mode
		db[1] = {name="VulDB",			file="scipvuldb.csv",		url="https://vuldb.com",			link="https://vuldb.com/id.{id}"}
		db[2] = {name="MITRE CVE",		file="cve.csv",			url="https://cve.mitre.org",			link="https://cve.mitre.org/cgi-bin/cvename.cgi?name={id}"}
		db[3] = {name="SecurityFocus",		file="securityfocus.csv",	url="https://www.securityfocus.com/bid/",	link="https://www.securityfocus.com/bid/{id}"}
		db[4] = {name="IBM X-Force",		file="xforce.csv",		url="https://exchange.xforce.ibmcloud.com",	link="https://exchange.xforce.ibmcloud.com/vulnerabilities/{id}"}
		db[5] = {name="Exploit-DB",		file="exploitdb.csv",		url="https://www.exploit-db.com",		link="https://www.exploit-db.com/exploits/{id}"}
		db[6] = {name="OpenVAS (Nessus)",	file="openvas.csv",		url="http://www.openvas.org",			link="https://www.tenable.com/plugins/nessus/{id}"}
		db[7] = {name="SecurityTracker",	file="securitytracker.csv",	url="https://www.securitytracker.com",		link="https://www.securitytracker.com/id/{id}"}
		db[8] = {name="OSVDB",			file="osvdb.csv",		url="http://www.osvdb.org",			link="http://www.osvdb.org/{id}"}

		stdnse.print_debug(1, "vulturescan: Using multi db mode (" .. #db .. " databases) ...")
		for i,v in ipairs(db) do
			vul = find_vulnerabilities(prod, ver, v.file)

			s = s .. v.name .. " - " .. v.url .. ":\n"
			if #vul > 0 then
					v_count = v_count + #vul
					s = s .. prepare_result(vul, struct, v.link) .. "\n"
			else
					s = s .. "No findings\n\n"
			end

			stdnse.print_debug(1, "vulturescan: " .. #vul .. " matches in " .. v.file)
		end

		stdnse.print_debug(1, "vulturescan: " .. v_count .. " matches in total")
	end

	if s then
		return s
	end
end

-- Find the product matches in the vulnerability databases
function find_vulnerabilities(prod, ver, db)
	local v = {}			-- matching vulnerabilities
	local v_id			-- id of vulnerability
	local v_title			-- title of vulnerability
	local v_title_lower		-- title of vulnerability in lowercase for speedup
	local v_found			-- if a match could be found

	-- Load database
	local v_entries = read_from_file("scripts/vulturescan/" .. db)

	-- Clean useless dataparts (speeds up search and improves accuracy)
	prod = string.gsub(prod, " httpd", "")
	prod = string.gsub(prod, " smtpd", "")
	prod = string.gsub(prod, " ftpd", "")

	local prod_words = strsplit(" ", prod)

	stdnse.print_debug(1, "vulturescan: Starting search of " .. prod ..
		" in " .. db ..
		" (" .. #v_entries .. " entries) ...")

	-- Iterate through the vulnerabilities in the database
	for i=1, #v_entries, 1 do
		v_id		= extract_from_table(v_entries[i], 1, ";")
		v_title		= extract_from_table(v_entries[i], 2, ";")

		if type(v_title) == "string" then
			v_title_lower = string.lower(v_title)

			-- Find the matches for the database entry
			for j=1, #prod_words, 1 do
				v_found = string.find(v_title_lower, escape(string.lower(prod_words[j])), 1)
				if type(v_found) == "number" then
					if #v == 0 then
						-- Initiate table
						v[1] = {
							id		= v_id,
							title	= v_title,
							product	= prod_words[j],
							version	= "",
							matches	= 1
						}
					elseif v[#v].id ~= v_id then
						-- Create new entry
						v[#v+1] = {
							id		= v_id,
							title	= v_title,
							product	= prod_words[j],
							version	= "",
							matches	= 1
						}
					else
						-- Add to current entry
						v[#v].product = v[#v].product .. " " .. prod_words[j]
						v[#v].matches = v[#v].matches+1
					end

					stdnse.print_debug(2, "vulturescan: Match v_id " .. v_id ..
						" -> v[" .. #v .. "] " ..
						"(" .. v[#v].matches .. " match) " ..
						"(Prod: " .. prod_words[j] .. ")")
				end
			end

			-- Additional version matching
			if nmap.registry.args.vulturescan_vd ~= "0" and ver ~= nil and ver ~= "" then
				if v[#v] ~= nil and v[#v].id == v_id then
					for k=0, string.len(ver)-1, 1 do
						v_version = string.sub(ver, 1, string.len(ver)-k)
						v_found = string.find(string.lower(v_title), string.lower(" " .. v_version), 1)

						if type(v_found) == "number" then
							v[#v].version = v[#v].version .. v_version .. " "
							v[#v].matches = v[#v].matches+1

							stdnse.print_debug(2, "vulturescan: Match v_id " .. v_id ..
								" -> v[" .. #v .. "] " ..
								"(" .. v[#v].matches .. " match) " ..
								"(Version: " .. v_version .. ")")
						end
					end
				end
			end
		end
	end

	return v
end

-- Prepare the resulting matches
function prepare_result(v, struct, link)
	local grace = 0				-- grace trigger
	local match_max = 0			-- counter for maximum matches
	local match_max_title = ""	-- title of the maximum match
	local s = ""				-- the output string

	-- Search the entries with the best matches
	if #v > 0 then
		-- Find maximum matches
		for i=1, #v, 1 do
			if v[i].matches > match_max then
				match_max = v[i].matches
				match_max_title = v[i].title
			end
		end

		stdnse.print_debug(2, "vulturescan: Maximum matches of a finding are " ..
			match_max .. " (" .. match_max_title .. ")")

		if match_max > 0 then
			for matchpoints=match_max, 1, -1 do
				for i=1, #v, 1 do
					if v[i].matches == matchpoints then
						stdnse.print_debug(2, "vulturescan: Setting up result id " .. i)
						s = s .. report_parsing(v[i], struct, link)
					end
				end

				if nmap.registry.args.vulturescan_all ~= "1" and s ~= "" then
					-- If the next iteration shall be approached (increases matches)
					if grace == 0 then
						stdnse.print_debug(2, "vulturescan: Best matches found in 1st pass. Going to use 2nd pass ...")
						grace = grace+1
					elseif nmap.registry.args.vulturescan_all ~= "1" then
						break
					end
				end
			end
		end
	end

	return s
end

-- Parse the report output structure
function report_parsing(v, struct, link)
	local s = struct

	--database data (needs to be first)
	s = string.gsub(s, "{link}", escape(link))

	--layout elements (needs to be second)
	s = string.gsub(s, "\\n", "\n")
	s = string.gsub(s, "\\t", "\t")

	--vulnerability data (needs to be third)
	s = string.gsub(s, "{id}", escape(v.id))
	s = string.gsub(s, "{title}", escape(v.title))
	s = string.gsub(s, "{matches}", escape(v.matches))
	s = string.gsub(s, "{product}", escape(v.product))	
	s = string.gsub(s, "{version}", escape(v.version))

	return s
end

-- Get the row of a CSV file
function extract_from_table(line, col, del)
	local val = strsplit(del, line)

	if type(val[col]) == "string" then
		return val[col]
	end
end

-- Read a file
function read_from_file(file)
	local filepath = nmap.fetchfile(file)

	if filepath then
		local f, err, _ = io.open(filepath, "r")
		if not f then
			stdnse.print_debug(1, "vulturescan: Failed to open file" .. file)
		end

		local line, ret = nil, {}
		while true do
			line = f:read()
			if not line then break end
			ret[#ret+1] = line
		end

		f:close()

		return ret
	else
		stdnse.print_debug(1, "vulturescan: File " .. file .. " not found")
		return ""
	end
end

-- We don't like unescaped things
function escape(s)
	s = string.gsub(s, "%%", "%%%%")
	return s
end
