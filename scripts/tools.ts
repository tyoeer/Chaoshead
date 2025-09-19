

const Cmds: {[key:string]:CmdDesc} = {
	zip: {
		args: ["-h"],
		checks: ["Info-ZIP","Zip 3."],
	},
	unzip: {
		args: ["-h"],
		checks: ["Info-ZIP","UnZip 6."],
	},
	git: {
		args: ["--version"],
		checks: ["git version 2."],
	},
	"./appimagetool.AppImage": {
		args: ["--version"],
		// unfortunately no stable release less than 1 year old
		// check for build year in the hope of breaking catching API changes
		checks: ["appimagetool", "built on 2025-"],
	}
	/*curl: {
		args: ["--version"],
		checks: ["curl 8."],
	},*/
};


type CmdDesc = {
	args: string[],
	checks: string[],
	found?: boolean;
};


export async function checkMultiple(...tools: string[]): Promise<boolean> {
	for (const tool of tools) {
		if (!await checkExists(tool)) return false;
	}
	return true;
}

export async function ensureMultiple(...tools: string[]) {
	const allFound = await checkMultiple(...tools);
	if (!allFound) {
		console.log("Not all required cli tools could be found, exiting");
		Deno.exit(1);
	}
}

export async function checkExists(tool: string): Promise<boolean> {
	const desc = Cmds[tool];
	if (desc.found==null) {
		desc.found = await checkCmdRun(tool, desc.args, desc.checks);
	}
	return desc.found;
}

export async function checkCmdRun(cmd: string, args: string[], required_output_fragments: string[]): Promise<boolean> {
	try {
		const cmdObject = new Deno.Command(cmd, {args: args});
		const {code, stdout, stderr} = await cmdObject.output();
		if (code === 0) {
			const out_text = new TextDecoder().decode(stdout);
			for (const required_fragment of required_output_fragments) {
				if (!out_text.includes(required_fragment)) {
					console.log(`Output of command ${cmd} did not include required substring ${required_fragment}`);
					console.log(`Command ${cmd} output as text:`);
					console.log(out_text);
					return false;
				}
			}
			return true;
		} else {
			console.log(`Problem running ${cmd} to verify it exists as cli tool, exit code ${code}, stderr:`);
			console.log(stderr);
			return false;
		}
	} catch (error: unknown) {
		if (
			typeof(error)=="object" &&
			error != null &&
			"name" in error &&
			error.name=="NotFound" &&
			"code" in error &&
			error.code=="ENOENT"
		) {
			console.error(`Command ${cmd} could not be found`);
		} else {
			console.error(`Error executing command ${cmd}:`);
			console.error(error);
		}
		return false;
	}
}

export async function runCmd(cmd: string, args: string[], cwd?: string): Promise<string> {
	const opts: Deno.CommandOptions = {args: args};
	if (cwd) {
		opts.cwd = cwd;
	}
	const cmdObject = new Deno.Command(cmd, opts);
	const {code, stdout, stderr} = await cmdObject.output();
	if (code === 0) {
		const text = new TextDecoder().decode(stdout);
		if (text.length>0) {
			console.log(`Ran ${cmd}:`)
			console.log(text);
		}
		return text;
	} else {
		const msg = `Error running ${cmd} ${args}, exit code ${code}, cwd ${cwd}:`;
		console.error(msg);
		console.error("Stdout:", new TextDecoder().decode(stdout));
		console.error("Stderr:", new TextDecoder().decode(stderr));
		throw msg;
	}
}