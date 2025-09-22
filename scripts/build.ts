const ChWindows32Name = "chaoshead-windows-x32";
const ChAppImageName = "chaoshead-linux-AppImage-x64";


import * as Tools from "./tools.ts";
import * as Publish from "./publish.ts";
import * as Love from "./love.ts";


export async function fileExists(filepath: string): Promise<boolean> {
	try {
		const stats = await Deno.lstat(filepath);
		return stats.isFile;
	} catch (error) {
		if (!(error instanceof Deno.errors.NotFound)) {
			throw error;
		}
		return false;
	}
}


export async function fsExists(path: string): Promise<boolean> {
	try {
		const _stats = await Deno.lstat(path);
		return true;
	} catch (error) {
		if (!(error instanceof Deno.errors.NotFound)) {
			throw error;
		}
		return false;
	}
}


export async function addMiscFiles(folder: string) {
	async function addFile(file: string, rename?: string) {
		const target = rename ?? file;
		await Deno.copyFile(`../${file}`,`${folder}/${target}`);
	}
	await addFile("credits.txt");
	await addFile("README.md");
	await addFile("LICENSE.txt","license-Chaoshead.txt");
	
	const licenseDir = folder+"/licenses/"
	await Deno.mkdir(licenseDir);
	for await (const dirEntry of await Deno.readDir("../licenses")) {
		if (!dirEntry.isFile) {
			throw `non-file "${dirEntry.name}" in licenses directory`;
		}
		await Deno.copyFile(`../licenses/${dirEntry.name}`, licenseDir+dirEntry.name);
	}
	
	const docsDir = folder+"/scriptDocs/"
	await Deno.mkdir(docsDir);
	for await (const dirEntry of await Deno.readDir("../docs")) {
		if (!dirEntry.isFile) {
			throw `non-file "${dirEntry.name}" in docs directory`;
		}
		await Deno.copyFile(`../docs/${dirEntry.name}`, docsDir+dirEntry.name);
	}
}


export async function buildAndPackageWindows32() {
	console.log("Creating Windows executable");
	
	//Prep basic LÖVE folder
	if (!await fileExists("love-windows32.zip")) {
		throw `Missing love-windows32.zip. Consider downloading it (love-windows32).`;
	}
	await Tools.runCmd("unzip", ["love-windows32.zip"]);
	await Deno.rename(Love.Windows32Name, ChWindows32Name);
	
	//fuse .love into Chaoshead.exe
	const dotLove = await Deno.open("chaoshead.love", {read: true});
	const dotExe = await Deno.open(ChWindows32Name+"/love.exe", {append: true});
	await dotLove.readable.pipeTo(dotExe.writable);
	try {
		dotLove.close();
	} catch (err) {
		// BadResource means already closed, which the pipeTo can do
		if (!(err instanceof Deno.errors.BadResource)) throw err;
	}
	try {
		dotExe.close();
	} catch (err) {
		// BadResource means already closed, which the pipeTo can do
		if (!(err instanceof Deno.errors.BadResource)) throw err;
	}
	await Deno.rename(ChWindows32Name+"/love.exe", ChWindows32Name+"/Chaoshead.exe")
	
	//cleanup
	await Deno.remove(ChWindows32Name+"/changes.txt");
	await Deno.remove(ChWindows32Name+"/game.ico");
	await Deno.remove(ChWindows32Name+"/love.ico");
	await Deno.remove(ChWindows32Name+"/lovec.exe");
	await Deno.remove(ChWindows32Name+"/readme.txt");
	
	//add other files
	await Deno.copyFile("../https32.dll", ChWindows32Name + "/https.dll");
	await Deno.rename(ChWindows32Name+"/license.txt", ChWindows32Name+"/license-love2d.txt");
	await addMiscFiles(ChWindows32Name);
	
	await Tools.runCmd("zip", ["--recurse-paths", "--filesync", "--move", `../packages/${ChWindows32Name}.zip`, ".", "-i", "*"], ChWindows32Name);
	await Deno.remove(ChWindows32Name);
}


export async function buildAndPackageLinuxAppImage() {
	console.log("Creating Linux AppImage");
	
	if (!await fileExists("appimage-runtime-x64")) {
		throw `Missing appimage-runtime-x64. Consider downloading it (appimage-runtime-x64).`;
	}
	await Deno.mkdir(ChAppImageName);
	
	//Extract AppImage dir
	if (!await fileExists("love-appimage64.zip")) {
		throw `Missing love-appimage64.zip. Consider downloading it (love-appimage).`;
	}
	await Tools.runCmd("unzip", ["love-appimage64.zip"]);
	
	// fuse .love
	const dotLove = await Deno.open("chaoshead.love", {read: true});
	const executable = await Deno.open("squashfs-root/bin/love", {append: true});
	await dotLove.readable.pipeTo(executable.writable);
	try {
		dotLove.close();
	} catch (err) {
		// BadResource means already closed, which the pipeTo can do
		if (!(err instanceof Deno.errors.BadResource)) throw err;
	}
	try {
		executable.close();
	} catch (err) {
		// BadResource means already closed, which the pipeTo can do
		if (!(err instanceof Deno.errors.BadResource)) throw err;
	}
	await Deno.rename("squashfs-root/bin/love", "squashfs-root/bin/Chaoshead");
	
	// patch .desktop
	const desktopOld = await Deno.readTextFile("squashfs-root/love.desktop");
	const desktopNew = [];
	for (const line of desktopOld.split('\n')) {
		if (line.startsWith("Exec=")) {
			desktopNew.push("Exec=Chaoshead %f");
		} else if (line.startsWith("Name=")) {
			desktopNew.push("Name=Chaoshead");
		// } else if (line.startsWith("Icon=")) {
		// 	desktopNew.push("Icon=Chaoshead");
		} else if (line.startsWith("Comment=")) {
			desktopNew.push("Comment=An external level editor for Levelhead");
		} else {
			desktopNew.push(line)
		}
	}
	await Deno.writeTextFile("squashfs-root/Chaoshead.desktop", desktopNew.join('\n'));
	await Deno.remove("squashfs-root/love.desktop");
	
	// await Deno.copyFile("../ChaosheadLogo.png","squashfs-root/Chaoshead.png");
	
	// patch AppRun
	const appRunOld = await Deno.readTextFile("squashfs-root/AppRun");
	const appRunNew = [];
	for (const line of appRunOld.split('\n')) {
		if (line.includes("exec")) {
			appRunNew.push(`exec "$APPDIR/bin/Chaoshead" "$@"`);
		} else if (line.startsWith("export LUA_CPATH")) {
			appRunNew.push(`export LUA_CPATH="$APPDIR/lib/lua/5.1/?.so;$APPDIR/lib/?.so;$LUA_CPATH"`);
		} else {
			appRunNew.push(line)
		}
	}
	await Deno.writeTextFile("squashfs-root/AppRun", appRunNew.join('\n'));
	
	// add https lib
	await Deno.copyFile("../https.so", "squashfs-root/lib/https.so");
	
	// copy out license + misc files
	await Deno.copyFile("squashfs-root/license.txt", ChAppImageName+"/license-love2d.txt");
	await addMiscFiles(ChAppImageName);
	
	// build into appImage
	await Tools.runCmd("./appimagetool.AppImage", ["--runtime-file", "appimage-runtime-x64", "squashfs-root", ChAppImageName+"/Chaoshead.AppImage"]);
	await Deno.remove("squashfs-root", {recursive: true});
	
	// package
	await Tools.runCmd("zip", ["--recurse-paths", "--filesync", "--move", `../packages/${ChAppImageName}.zip`, ".", "-i", "*"], ChAppImageName);
	await Deno.remove(ChAppImageName);
}


export async function build() {
	await Tools.ensureMultiple("zip", "unzip", "git", "./appimagetool.AppImage");
	
	let oldVersion = await Tools.runCmd("git", ["describe", "--tags", "--abbrev=0"], "..");
	oldVersion = oldVersion.trim();
	console.log(`Enter the version (Major.Minor.Patch), previous is ${oldVersion}`);
	const version = prompt("Version:")
	if (!version) throw "No version given";
	const versionRegex = /^\d+\.\d+\.\d+$/;
	if (!version.match(versionRegex)) throw `Version \"${version}\" is not formatted as a version`;
	
	if (await fsExists("packages")) {
		await Deno.remove("packages",{recursive:true});
	}
	await Deno.mkdir("packages");
	
	console.log("Creating chaoshead.love");
	await Tools.runCmd("zip", ["--recurse-paths", "--filesync", "-9", "../build/chaoshead-love.zip", ".", "-i", "*"], "../src");
	await Deno.writeTextFile("version.txt", version);
	await Tools.runCmd("zip", ["chaoshead-love.zip", "version.txt"]);
	await Deno.rename("chaoshead-love.zip", "chaoshead.love");
	
	await buildAndPackageWindows32();
	await buildAndPackageLinuxAppImage();
	
	const releaseNotes = await Tools.runCmd("git", ["log", `${oldVersion}..HEAD` , `--format=format:"> %s%+b"`]);
	await Deno.writeTextFile(Publish.releaseNotesFile, releaseNotes);
	// create git tag
}

/*
Download LÖVE windows 32 base
Download LÖVE AppImage base
Download & build https libraries?
Download AppImage tools
*/

