const Downloads: DownloadsType = {
	"love-windows32": {
		url: Love.Windows32Url,
		file: "love-windows32.zip",
		desc: "Windows x32 LÖVE",
	},
	"love-appimage": {
		url: Love.AppImageUrl,
		file: "love-appimage64.AppImage",
		desc: "LÖVE Linux x64 AppImage",
		post: async () => {
			await Deno.chmod("love-appimage64.AppImage", 0o555);
			await Tools.ensureMultiple("zip");
			await Tools.runCmd("./love-appimage64.AppImage", ["--appimage-extract"]);
			await Tools.runCmd("zip", ["--recurse-paths", "--move", "--filesync", "love-appimage64.zip", "squashfs-root"]);
			await Deno.remove("love-appimage64.AppImage");
		},
	},
	"appimagetool": {
		// https://github.com/AppImage/appimagetool/releases
		url: "https://github.com/AppImage/appimagetool/releases/latest/download/appimagetool-x86_64.AppImage",
		file: "appimagetool.AppImage",
		desc: "appimagetool",
		post: async () => {
			await Deno.chmod("appimagetool.AppImage", 0o555);
		},
	},
	"appimage-runtime-x64": {
		url: "https://github.com/AppImage/type2-runtime/releases/latest/download/runtime-x86_64",
		file: "appimage-runtime-x64",
		desc: "AppImage x64 runtime",
	}
};

import * as Tools from "./tools.ts";
import * as Love from "./love.ts";

type DownloadsType = {
	[key: string]: {
		url:string,
		file:string,
		desc:string,
		post?: () => Promise<void>,
	}
};

export async function checkTools() {
	// await Tools.ensureMultiple("unzip");
}

export async function downloadToFile(url: string, filepath: string) {
	// await Tools.runCmd("curl", ["--output", file, url]);
	const response = await fetch(url);
	// enable reading +writing, some things we download are tools and get set to !write and execute
	await Deno.chmod(filepath, 0o666);
	const file = await Deno.create(filepath);
	await response.body?.pipeTo(file.writable);
}

export async function downloadKnown(id:string) {
	const opts = Downloads[id];
	if (!opts) {
		console.error("Available downloads:",Object.keys(Downloads));
		throw `Unknown download ${id}`;
	}
	console.log(`Downloading ${opts.desc}`);
	await downloadToFile(opts.url, opts.file);
	if (opts.post) {
		await opts.post();
	}
}