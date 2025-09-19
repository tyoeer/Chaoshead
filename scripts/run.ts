import * as Download from "./download.ts";
import * as Build from "./build.ts";

await Deno.permissions.request({name:"read",path:"build/"});
await Deno.permissions.request({name:"write",path:"build/"});
Deno.chdir("build/");
console.log("Moved/cd'd into build/");

const subCommand = Deno.args[0];
if (subCommand=="dl" || subCommand=="download") {
	await Download.checkTools();
	await Download.downloadKnown(Deno.args[1]);
} else if (subCommand=="package" || subCommand=="build") {
	await Build.build();
} else {
	console.log(`Invalid subcommand ${subCommand}`);
	console.log(`Valid subcommands: download (aliases: dl), package (aliases: build)`);
	Deno.exit(1);
}