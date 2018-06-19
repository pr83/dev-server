import jenkins.model.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*

def jenkins = Jenkins.getInstance()
def domain = Domain.global()

def store = jenkins.getExtensionList(
  'com.cloudbees.plugins.credentials.SystemCredentialsProvider'
  )[0].getStore()

  
store.addCredentials(
    domain,
    new UsernamePasswordCredentialsImpl(
        CredentialsScope.GLOBAL,
        "{{ item.id }}",
        "{{ item.description }}",
        "{{ item.username }}",
        "{{ item.password }}"
    )
)