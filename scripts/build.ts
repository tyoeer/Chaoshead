



async function checkCliToolExists(cmd: string, args: string[], required_output_fragments: string[]): Promise<boolean> {
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

async function validateTools(): Promise<boolean> {
	let allFound = true;
	allFound &&= await checkCliToolExists("zip", ["-h"], ["Info-ZIP","Zip 3.0"]);
	allFound &&= await checkCliToolExists("git", ["--version"], ["git version 2."]);
	return allFound;
}

async function runCmd(cmd: string, args: string[], cwd?: string): Promise<string> {
	const opts: Deno.CommandOptions = {args: args};
	if (cwd) {
		opts.cwd = cwd;
	}
	const cmdObject = new Deno.Command(cmd, opts);
	const {code, stdout, stderr} = await cmdObject.output();
	if (code === 0) {
		return new TextDecoder().decode(stdout);
	} else {
		const msg = `Error running ${cmd} ${args}, exit code ${code}, cwd ${cwd}:`;
		console.error(msg);
		console.error("Stdout:", new TextDecoder().decode(stdout));
		console.error("Stderr:", new TextDecoder().decode(stderr));
		throw msg;
	}
}


async function build() {
	const oldVersion = await runCmd("git", ["describe", "--tags", "--abbrev=0"], "..");
	console.log(`Enter the version (Major.Minor.Patch), previous is ${oldVersion}`);
	const version = prompt("Version:")
	if (!version) throw "No version given";
	const versionRegex = /^\d+\.\d+\.\d+$/;
	if (!version.match(versionRegex)) throw `Version \"${version}\" is not formatted as a version`;
	
	console.log("Creating chaoshead.love");
	await runCmd("zip", ["--recurse-paths", "--filesync", "-9", "../build/chaoshead-love.zip", ".", "-i", "*"], "../src");
	await Deno.writeTextFile("version.txt", version);
	await runCmd("zip", ["chaoshead-love.zip", "version.txt"]);
	await Deno.rename("chaoshead-love.zip", "chaoshead.love");
	
	// build windows
	// https
	// build AppImage
	// https
	/* attach lots of things
	licenses
	CH license
	love2d license
	credits
	README
	*/
	// changelog: git log $(git describe --tags --abbrev=0)..HEAD --format=format:"> %s%+b" > commits.txt
	// create git tag
}


const toolsGood = await validateTools();
if (!toolsGood) {
	console.log("Not all required cli tools could be found, exiting");
	Deno.exit(1);
}


//get ahead of things, we'l do multiple things in the directory
await Deno.permissions.request({name:"read",path:"build/"});
await Deno.permissions.request({name:"write",path:"build/"});
Deno.chdir("build/");
console.log("Moved/cd'd into build/");


await build();
