import { mkdir, readdir, writeFile, rmdir, cp } from 'node:fs/promises';
import type { Project, ProjectInfo } from './types';

export async function saveProject(project: Project, isCreating: boolean = false) {
    if(project.info.name.length < 1) return;
    await mkdir(PROJECT_PATH, { recursive: true });
    await mkdir(projectDir(project.info), { recursive: !isCreating });

    const versions = await listVersions(project.info);

    const lastVersion = versions[versions.length - 1];
    project.info.version = (lastVersion ?? -1) + 1;

    await writeFile(
        projectDir(project.info) + `/v${project.info.version}.json`,
        JSON.stringify(project)
    );
}

export async function loadProject(name: string, version: number) {
    const file = Bun.file(`${PROJECT_PATH}/${name}/v${version}.json`);
    const project = await file.json();
    return project;
}

export async function updateConfig(name: string, version: number, info: ProjectInfo) {
    const project = await loadProject(name, version);
    project.info = info;
    await saveProject(project);
}

export async function listProjects() {
    const folders = await readdir(PROJECT_PATH);

    let projects: ProjectInfo[] = [];

    for(let i = 0; i < folders.length; i++) {
        const projectFiles = await readdir(`${PROJECT_PATH}/${folders[i]}`);
        const versions = getVersionsFromFileList(projectFiles);

        const latestVersion = versions[versions.length - 1];
        const file = Bun.file(`${PROJECT_PATH}/${folders[i]}/v${latestVersion}.json`);
        const project = await file.json();
        projects.push({
            ...project.info,
            version: latestVersion,
            musicFile: undefined,
        });
    }

    return projects;
}

export async function deleteProject(name: string) {
    await rmdir(`${PROJECT_PATH}/${name}`, { recursive: true });
}

async function listVersions(info: ProjectInfo): Promise<number[]> {
    const versions = await readdir(projectDir(info));
    return getVersionsFromFileList(versions);
}

function getVersionsFromFileList(versions: string[]): number[] {
    return versions.map(v => parseInt(v.slice(1, v.indexOf('.')))).sort();
}

const PROJECT_PATH = './projects';
const projectDir = (p: ProjectInfo) => `${PROJECT_PATH}/${p.name}`;
