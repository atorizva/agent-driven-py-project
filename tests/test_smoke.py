import agent_driven_py_project


def test_version() -> None:
    assert agent_driven_py_project.__version__ == "0.1.0"


def test_main(capsys) -> None:
    agent_driven_py_project.main()
    assert "Hello" in capsys.readouterr().out
