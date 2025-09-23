
export const releaseNotesFile = "releaseNotes.md";


let vVersion: string;
let versionRaw: string;

type Release = {
	name: string,
	tag: string,
	notes: string
}

export async function publishGithub(release: Release) {
	const token = Deno.env.get("GITHUB_TOKEN");
	if (!token) {
		throw `Missing GitHub token (should be GITHUB_TOKEN env var)`;
	}
	const headers: HeadersInit = {
		Accept: "application/vnd.github+json",
		Authorization: `Bearer ${token}`,
		"X-GitHub-Api-Version": "2022-11-28",
	};
	// cont new = {...old, ...other}
	const response = await fetch("https://api.github.com/repos/tyoeer/Chaoshead/releases", {
		headers: headers,
		method: "POST",
		body: JSON.stringify({
			tag_name: release.tag,
			name: release.name,
			body: release.notes,
			draft: true,
		}),
	});
	
	if (response.status < 200 || response.status > 299) {
		console.error(response);
		console.error(await response.text());
		throw `Github API call to make release returned non-2xx response`;
	}
	const ghRelease = await response.json();
	
	console.log(`Created draft GitHub release ${release.name} at ${ghRelease.html_url}`);
	
	//regex to remove the {?name,label} at the end. include the percent-encoded stuff due to paranoia (it got returned in an error message from GH)
	const uploadUrl = ghRelease.upload_url.replaceAll(/(\{|\%7B)[^{}]*(\}|%7D)/g, "");
	
	for await (const dirEntry of await Deno.readDir("packages")) {
		const name = dirEntry.name;
		if (!dirEntry.isFile) {
			throw `non-file "${name}" in packages/ directory`;
		}
		const path = "packages/" + name;
		
		let contentType: string;
		
		if (name.endsWith(".zip")) {
			contentType = "application/zip";
		} else {
			throw `Unknown file extension for package/${name}`;
		}
		
		// streaming does not work, errors with "message":"Bad Content-Length"
		// const packageFile = await Deno.open(path, {read: true});
		// const packageFileStats = await packageFile.stat();
		// const contentLength = packageFileStats.size.toString();
		// packageFile.close();
		
		const data = await Deno.readFile(path);
		
		const response = await fetch(uploadUrl+`?name=${name}`, {
			headers: {
				...headers,
				"Content-Type": contentType,
				"Content-Length": data.byteLength.toString(),
				// "Content-Length": contentLength,
			},
			method: "POST",
			body: data,
			// body: packageFile.readable,
		});

		if (response.status < 200 || response.status > 299) {
			console.error(response);
			console.error(await response.text());
			throw `Github API call to add release file ${name} returned non-2xx response`;
		}
		
		console.log(`Uploaded release package ${name} to Github`);
	}
}

export async function publishCodeberg(release: Release) {
	const token = Deno.env.get("CODEBERG_TOKEN");
	if (!token) {
		throw `Missing Codeberg token (should be CODEBERG_TOKEN env var)`;
	}
	const headers: HeadersInit = {
		Accept: "application/json",
		"Content-Type": "application/json",
		Authorization: `Bearer ${token}`,
	};
	// cont new = {...old, ...other}
	const response = await fetch("https://codeberg.org/api/v1/repos/tyoeer/Chaoshead/releases", {
		headers: headers,
		method: "POST",
		body: JSON.stringify({
			tag_name: release.tag,
			name: release.name,
			body: release.notes,
			draft: true,
		}),
	});
	
	if (response.status < 200 || response.status > 299) {
		console.error(response);
		console.error(await response.text());
		throw `Codeberg API call to make release returned non-2xx response`;
	}
	const cbRelease = await response.json();
	
	console.log(`Created draft Codeberg release ${cbRelease.name} at ${cbRelease.html_url}`);
	
	//regex to remove the {?name,label} at the end. include the percent-encoded stuff due to paranoia (it got returned in an error message from GH)
	const uploadUrl = cbRelease.upload_url;
	
	for await (const dirEntry of await Deno.readDir("packages")) {
		const name = dirEntry.name;
		if (!dirEntry.isFile) {
			throw `non-file "${name}" in packages/ directory`;
		}
		const path = "packages/" + name;
		
		let contentType: string;
		
		if (name.endsWith(".zip")) {
			contentType = "application/zip";
		} else {
			throw `Unknown file extension for package/${name}`;
		}
		
		const data = await Deno.readFile(path);
		
		const formData = new FormData();
		formData.append("attachment", new Blob([data], {
			type: contentType,
		}));
		
		const response = await fetch(uploadUrl+`?name=${name}`, {
			headers: {
				...headers,
			},
			method: "POST",
			body: formData,
		});

		if (response.status < 200 || response.status > 299) {
			console.error(response);
			console.error(await response.text());
			throw `Codeberg API call to add release file ${name} returned non-2xx response`;
		}
		
		console.log(`Uploaded release package ${name} to Codeberg`);
	}
}


export async function publish(target: string) {
	versionRaw = await Deno.readTextFile("version.txt");
	vVersion = "v" + versionRaw;
	const notes = await Deno.readTextFile(releaseNotesFile);
	
	const release: Release = {
		name: `Chaoshead ${vVersion}`,
		tag: vVersion,
		notes: notes,
	};
	
	if (target=="github" || target=="gh") {
		publishGithub(release);
	} else if (target=="codeberg" || target=="cb") {
		publishCodeberg(release);
	} else {
		console.error("Available publish targets: github/gh, codeberg/cb");
		throw `Invalid publish target: ${target}`;
	}
}