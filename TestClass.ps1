Write-Host "✅ HelloWorld class loaded"
class HelloWorld {
    [string]$Message

    HelloWorld([string]$msg) {
        $this.Message = $msg
    }

    [string]SayHello() {
        return "Hello: $($this.Message)"
    }
}