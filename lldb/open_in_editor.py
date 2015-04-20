#!/usr/bin/env python

import os

def __lldb_init_module(debugger, internal_dict):
    cmd = 'command script add -f open_in_editor.open_in_editor open_in_editor'
    debugger.HandleCommand(cmd)

def open_in_editor(debugger, command, result, internal_dict):
    ''' Open the current frame's file in emacsclient '''
    lldb = LLDBContext(debugger)
    if not lldb.frame.IsValid():
        result.SetError('No current frame')
        return
    template = 'emacsclient -n +{0.line}:{0.column} {0.file}'
    os.system(template.format(lldb.frame.line_entry))

class LLDBContext(object):
    def __init__(self, debugger):
        self.target = debugger.GetSelectedTarget()
        self.process = self.target.GetProcess()
        self.thread = self.process.GetSelectedThread()
        self.frame = self.thread.GetSelectedFrame()
