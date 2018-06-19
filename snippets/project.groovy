import hudson.model.AbstractItem
import hudson.model.Project
import hudson.tasks.Builder
import hudson.triggers.SCMTrigger
import jenkins.model.Jenkins;
import hudson.model.FreeStyleProject;
import hudson.tasks.Shell;
import hudson.plugins.git.*;

def job = Jenkins.getInstance().getItemByFullName("job_name", AbstractItem)

Project project = project(
        "{{ item.name }}",
        "{{ item.gitUrl }}",
        "{{ item.gitBranch }}",
        "{{ item.gitCredentialsId }}",
        "{{ item.gitPollCron }}",
        "{{ item.buildScript }}"
);

project.save()
project.scheduleBuild()
project.schedulePolling()


private static FreeStyleProject project(
        String name,
        String gitUrl,
        String gitBranch,
        String gitCredentialsId,
        String gitPollCron,
        String buildScript) {

    def job = Jenkins.instance.createProject(FreeStyleProject, name)

    gitScm(gitUrl, gitBranch, gitCredentialsId).

    job.setScm(gitScm(gitUrl, gitBranch, gitCredentialsId))
    job.addTrigger(scmTrigger(gitPollCron))
    job.buildersList.add(builder(buildScript))

    return job;
}

private static gitScm(String url, String branch, String credentialsId) {
    return new GitSCM(
        remoteConfigs(url, credentialsId),
        branchSpecs(branch),
        false,
        Collections.emptyList(),
        null,
        null,
        Collections.emptyList()
    )
}

private static List<UserRemoteConfig> remoteConfigs(String url, String credentialsId) {
    return Collections.singletonList(
        new UserRemoteConfig(
            url,
            null,
            null,
            credentialsId
        )
    );
}

private static List<BranchSpec> branchSpecs(String branch) {
    return Collections.singletonList(new BranchSpec(branch))
}

private static SCMTrigger scmTrigger(String cron) {
    return new SCMTrigger(cron)
}

private static Builder builder(String script) {
    return new Shell(script)
}