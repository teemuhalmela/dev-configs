import sublime
import sublime_plugin
import subprocess

# https://gist.github.com/coldnebo/1138554
# http://www.bergspot.com/blog/2012/05/formatting-xml-in-sublime-text-2-xmllint/
# https://gist.github.com/jensens/4fc631616f5ef9ac4c6b

# NOTE: This needs jq.
# sudo apt install jq

class JsonppCommand(sublime_plugin.TextCommand):
    def run(self, edit):
        command = 'jq \'.\''

        if self.view.sel()[0].empty():
          jsonRegion = sublime.Region(0, self.view.size())
        else:
          jsonRegion = self.view.sel()[0]

        p = subprocess.Popen(command, bufsize=-1, stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.PIPE, shell=True)
        result, err = p.communicate(self.view.substr(jsonRegion).encode('utf-8'))

        if err:
          self.view.set_status('jsonpp', "jsonpp: "+err.decode('utf-8'))
          sublime.set_timeout(self.clear,10000)
        else:
          self.view.replace(edit, jsonRegion, result.decode('utf-8'))
          sublime.set_timeout(self.clear,0)

    def clear(self):
        self.view.erase_status('jsonpp')
