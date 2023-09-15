from typing import Optional, Callable, Dict
import ast
import contextlib
import faulthandler
import io
import os
import multiprocessing
import platform
import signal
import tempfile

import subprocess
import re
from threading import Timer

def clean_up_simulation() -> None:
    """
    kill all simulation process.
    """
    print("Killing all hanging simulation process.")
    subprocess.run("pkill iverilog", shell=True)
    subprocess.run("pkill vvp", shell=True)

def check_correctness(problem: Dict, completion: str, timeout: float,
                      completion_id: Optional[int] = None, unit_test_length: Optional[int] = None) -> Dict:
    """
    Evaluates the functional correctness of a completion by running the test
    suite provided in the problem. 
    :param completion_id: an optional completion ID so we can match
        the results later even if execution finishes asynchronously.
    """

    def unsafe_execute():

        with create_tempdir():

            # These system calls are needed when cleaning up tempdir.
            import os
            import shutil
            rmtree = shutil.rmtree
            rmdir = os.rmdir
            chdir = os.chdir

            # Disable functionalities that can make destructive changes to the test.
# WARNING
# subprocess.Popen is used to run shell command with calls to iveriog and vvp.
# Please refer to reliability_guard function for details
            reliability_guard()

            # Output testbench with solution to Verilog file in temp directory.
            verilog_test = problem["test"] + "\n" + \
                    problem["prompt"] + "\n" + \
                    completion

                
            if unit_test_length:
                keywords = re.findall("repeat\([0-9]*\)", verilog_test)
                for words in keywords:
                    verilog_test = verilog_test.replace(words, "repeat({})".format(unit_test_length))
                    
            with open("{}.sv".format(problem["task_id"]), 'w') as f:
                f.write(verilog_test)
            
            try:
# WARNING PLEASE READ
# The following code use subprocess.Popen to run shell command with calls to iveriog and vvp.
# Please check that iverilog and vvp are installed and included in your current run path.
# For installation of Icarus Verilog, please refer to: https://github.com/steveicarus/iverilog
# This program exists to execute untrusted model-generated code. Although
# it is highly unlikely that model-generated code will do something overtly
# malicious in response to this test suite, model-generated code may act
# destructively due to a lack of model capability or alignment.
# Users are strongly encouraged to sandbox this evaluation suite so that it 
# does not perform destructive actions on their host or network. For more 
# information on how OpenAI sandboxes its code, see the original OpenAI paper.
# Once you have read this disclaimer and taken appropriate precautions, 
# proceed at your own risk:
# BEGIN CODE BLOCK
"""
                with swallow_io():
                    with time_limit(timeout):
                        cmd = "iverilog -Wall -Winfloop -Wno-timescale -g2012 \
                                    -s tb -o test.vvp {}.sv; vvp -n test.vvp".format(problem["task_id"])
                       
                        """
                        adding timeout options for Popen. something breaks if not using timeout. seems to be working for now.
                        not really sure if its the best/correct way. let me know if anyone has a better solution.
                        https://stackoverflow.com/questions/1191374/using-module-subprocess-with-timeout
                        """
                        p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                        timer = Timer(timeout, p.kill)
                        try:
                            timer.start()
                            out, err = p.communicate()
                        finally:
                            timer.cancel()
                            
                        out, err = out.decode("utf-8"), err.decode("utf-8") 
                        match = re.search(r'Mismatches: ([0-9]*) in ([0-9]*) samples', out)
                        if "syntax error" in err:
                            result.append("failed: syntax error.")
                        elif len(err) > 0:
                            result.append("failed: compile error.")
                        elif match:
                            cor, tot = [int(i) for i in match.groups()]
                            if cor == 0:
                                result.append("passed")
                            else:
                                result.append(f"failed: {cor} out of {tot} samples.")
                        else:
                            result.append("failed: info string not matched.")
"""
# END CODE BLOCK
            except TimeoutException:
                result.append("timed out")
            except BaseException as e:
                result.append(f"failed: {e}")

            # Needed for cleaning up.
            shutil.rmtree = rmtree
            os.rmdir = rmdir
            os.chdir = chdir
            
    manager = multiprocessing.Manager()
    result = manager.list()

    p = multiprocessing.Process(target=unsafe_execute)
    p.start()
    p.join(timeout=timeout + 1)
    if p.is_alive():
        p.kill()

    if not result:
        result.append("timed out")

    return dict(
        task_id=problem["task_id"],
        passed=result[0] == "passed",
        result=result[0],
        completion_id=completion_id,
    )


@contextlib.contextmanager
def time_limit(seconds: float):
    def signal_handler(signum, frame):
        raise TimeoutException("Timed out!")
    signal.setitimer(signal.ITIMER_REAL, seconds)
    signal.signal(signal.SIGALRM, signal_handler)
    try:
        yield
    finally:
        signal.setitimer(signal.ITIMER_REAL, 0)


@contextlib.contextmanager
def swallow_io():
    stream = WriteOnlyStringIO()
    with contextlib.redirect_stdout(stream):
        with contextlib.redirect_stderr(stream):
            with redirect_stdin(stream):
                yield


@contextlib.contextmanager
def create_tempdir():
    with tempfile.TemporaryDirectory() as dirname:
        with chdir(dirname):
            yield dirname


class TimeoutException(Exception):
    pass


class WriteOnlyStringIO(io.StringIO):
    """ StringIO that throws an exception when it's read from """

    def read(self, *args, **kwargs):
        raise IOError

    def readline(self, *args, **kwargs):
        raise IOError

    def readlines(self, *args, **kwargs):
        raise IOError

    def readable(self, *args, **kwargs):
        """ Returns True if the IO object can be read. """
        return False


class redirect_stdin(contextlib._RedirectStream):  # type: ignore
    _stream = 'stdin'


@contextlib.contextmanager
def chdir(root):
    if root == ".":
        yield
        return
    cwd = os.getcwd()
    os.chdir(root)
    try:
        yield
    except BaseException as exc:
        raise exc
    finally:
        os.chdir(cwd)


def reliability_guard(maximum_memory_bytes: Optional[int] = None):
    """
    Updated Comment:
    We have enabled subprocess.Popen to allow shell command calls to verilog 
    compiler and simulator. Please use at own risk.
    Original Comment:
    This disables various destructive functions and prevents the generated code
    from interfering with the test (e.g. fork bomb, killing other processes,
    removing filesystem files, etc.)
    WARNING
    This function is NOT a security sandbox. Untrusted code, including, model-
    generated code, should not be blindly executed outside of one. See the 
    Codex paper for more information about OpenAI's code sandbox, and proceed
    with caution.
    """

    if maximum_memory_bytes is not None:
        import resource
        resource.setrlimit(resource.RLIMIT_AS, (maximum_memory_bytes, maximum_memory_bytes))
        resource.setrlimit(resource.RLIMIT_DATA, (maximum_memory_bytes, maximum_memory_bytes))
        if not platform.uname().system == 'Darwin':
            resource.setrlimit(resource.RLIMIT_STACK, (maximum_memory_bytes, maximum_memory_bytes))

    faulthandler.disable()

    import builtins
    builtins.exit = None
    builtins.quit = None

    import os
    os.environ['OMP_NUM_THREADS'] = '1'

    os.kill = None
    os.system = None
    os.putenv = None
    os.remove = None
    os.removedirs = None
    os.rmdir = None
    os.fchdir = None
    os.setuid = None
    os.fork = None
    os.forkpty = None
    os.killpg = None
    os.rename = None
    os.renames = None
    os.truncate = None
    os.replace = None
    #os.unlink = None
    os.fchmod = None
    os.fchown = None
    os.chmod = None
    os.chown = None
    os.chroot = None
    os.fchdir = None
    os.lchflags = None
    os.lchmod = None
    os.lchown = None
    os.getcwd = None
    os.chdir = None

    import shutil
    shutil.rmtree = None
    shutil.move = None
    shutil.chown = None

# WARNING
# subprocess.Popen is allowed and used to make shell command calls to verilog compiler and simulator.
    #import subprocess
    #subprocess.Popen = None  # type: ignore

    __builtins__['help'] = None

    import sys
    sys.modules['ipdb'] = None
    sys.modules['joblib'] = None
    sys.modules['resource'] = None
    sys.modules['psutil'] = None
    sys.modules['tkinter'] = None