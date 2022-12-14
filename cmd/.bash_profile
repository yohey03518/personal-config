# generated by Git for Windows
test -f ~/.profile && . ~/.profile
test -f ~/.bashrc && . ~/.bashrc

export KUBECONFIG=''
### PLEASE REVIEW THIS SECTION AND CHNAGE BASED ON YOUR ENVIRONMENT
alias rb='. ~/.bash_profile'
alias eb='vi ~/.bash_profile'
alias kp='get_k8s_env && kubectl get pods -n $K8S_NAMESPACE'
alias kpw='get_k8s_env && kubectl get pods -n $K8S_NAMESPACE -o wide'
alias k8s_ver='kubectl version'
alias idc_stag='export KUBECONFIG=$HOME/.kube/idc/stag/k8s.conf'
alias idc_prod='export KUBECONFIG=$HOME/.kube/idc/prod/k8s.conf'
alias cdol='cd /d/workspaces/gitlab/open-loyalty'
alias cdbc='cd /d/workspaces/gitlab/bacchus/'
alias cdqs='cd /d/workspaces/gitlab/quicksilver/'
###

function kap() {
    get_k8s_env
    get_k8s_confirm

    if [[ $k8s_confirm != "y" ]]; then
	return 1
    fi

    kubectl apply -f $1
}

function stag_ol() {
    idc_stag
    export K8S_NAMESPACE=openloyalty
}

function prod_ol() {
    idc_prod
    export K8S_NAMESPACE=openloyalty
}

function stag_bc() {
    idc_stag
    export K8S_NAMESPACE=staging-bacchus
}

function uat_bc() {
    idc_stag
    export K8S_NAMESPACE=uat-bacchus
}

function prod_bc() {
    idc_prod
    export K8S_NAMESPACE=production-bacchus
}

function get_k8s_env() {
    if [[ $K8S_NAMESPACE == *"bacchus"* ]]; then
	if [[ $K8S_NAMESPACE == "production"* ]]; then
	    echo -e "\033[33;3mproduction\033[0m"
	elif [[ $K8S_NAMESPACE == "uat"* ]]; then
	    echo -e "\033[33;5muat\033[0m"
        else
	    echo -e "\033[33;4mstaging\033[0m"
	fi
    elif [[ $KUBECONFIG == *"prod"* ]]; then
	echo -e "\033[33;3mproduction\033[0m"
    elif [[ $KUBECONFIG == *"stag"* ]]; then
	echo -e "\033[33;4mstaging\033[0m"
    else
	echo no env
    fi
}

function get_k8s_confirm() {
    k8s_confirm="n"
    read -p 'confirm(y/n):' k8s_confirm
}

function get_k8s_pod() {
    k8s_pod=`kubectl get pods -n $K8S_NAMESPACE | grep -v "backup" | grep "^$1" | cut -d " " -f 1`
    echo "$k8s_pod" | nl -b a
    read -p 'choice pod(ex: 1):' k8s_pod_choice
    k8s_pod=`kubectl get pods -n $K8S_NAMESPACE | grep -v "backup" | grep "^$1" | cut -d " " -f 1 | sed -n ${k8s_pod_choice}p`
    echo "target pod: $k8s_pod"
}

function get_k8s_common()
{
    get_k8s_env
    get_k8s_confirm
    get_k8s_pod $1
}

function kpdescp() {
    get_k8s_common $1

    if [[ $k8s_confirm != "y" ]]; then
	return 1
    fi

    kubectl describe pods "$k8s_pod" -n $K8S_NAMESPACE
}

function kpgd() {
    get_k8s_common $1

    if [[ $k8s_confirm != "y" ]]; then
	return 1
    fi

    kubectl delete pod "$k8s_pod" --grace-period=0 --force --namespace $K8S_NAMESPACE
}

function kpl() {
    get_k8s_common $1

    if [[ $k8s_confirm != "y" ]]; then
	return 1
    fi

    kubectl exec -it "$k8s_pod" -n $K8S_NAMESPACE bash
}

function kplog() {
    get_k8s_common $1

    if [[ $k8s_confirm != "y" ]]; then
	return 1
    fi

    kubectl logs "$k8s_pod" -n $K8S_NAMESPACE
}

function kplogf() {
    get_k8s_common $1

    if [[ $k8s_confirm != "y" ]]; then
	return 1
    fi

    kubectl logs -f "$k8s_pod" -n $K8S_NAMESPACE
}

function ked() {
    get_k8s_common $1

    if [[ $k8s_confirm != "y" ]]; then
	return 1
    fi

    kubectl edit deploy "$1" -n $K8S_NAMESPACE
}

function kpsp() {
    get_k8s_env
    get_k8s_confirm

    if [[ $k8s_confirm != "y" ]]; then
	return 1
    fi

    kubectl scale deployment $1 --replicas=$2 -n $K8S_NAMESPACE
}

function kpmn() {
    if [[ $KUBECONFIG == *"prod"* ]]; then
	k8s_hostname="k8s-prod-0"
    elif [[ $KUBECONFIG == *"stag"* ]]; then
	k8s_hostname="k8s-stg-0"
    fi
    kubectl patch deployment $1 -n $K8S_NAMESPACE -p "{\"spec\":{\"template\":{\"spec\":{\"nodeSelector\":{\"kubernetes.io/hostname\":\"$k8s_hostname$2\"}}}}}"

    echo "graceful delete $1 pod?"
    kpgd $1
}

function gp() {
    git pull
}
function git_pusj() {
    git push
}
function gitpush() {
    git push
}
function gs() {
	git status
}

function gca(){
	git stage -A
	git commit -a
}

function gco() {
	git checkout $1
}

alias res='restart_apppool'
function restart_apppool(){
	appcmd recycle apppool $1
	appcmd stop site $1
	appcmd start site $1	
}

function npr(){
	npm run serve
}

function vs(){
	start *.sln
}

docker()
{
    (export MSYS_NO_PATHCONV=1; "docker.exe" "$@")
}

function sleep(){
	taskkill //F //IM openvpn.exe
	shutdown -h
}

function aaa_bbb(){
	git pull
}

function hostfile(){
	"C:\Program Files\Notepad++\notepad++.exe" /c/Windows/System32/drivers/etc/hosts
}

function gpts() {
	"C:\Users\erwin.chang73\Desktop\commands\pull-team-shared.sh"
}

