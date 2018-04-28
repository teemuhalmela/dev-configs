import sublime
import sublime_plugin


class ShowLastLine(sublime_plugin.EventListener):
    def on_post_save(self, view):
        self.showLastLine(view)

    def on_load_async(self, view):
        self.showLastLine(view)

    def showLastLine(self, view):
        lastLinePoint = view.size()
        lastLineRegion = view.line(lastLinePoint)
        view.add_regions("mark", [lastLineRegion], "mark", "dot",
            sublime.HIDDEN)
