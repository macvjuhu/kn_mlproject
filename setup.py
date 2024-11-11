from setuptools import setup, find_packages

HYPEN_E_DOT = '-e .'

def get_requirements(filename):
    with open(filename, 'r') as f:
        requirements = f.read().splitlines()

    if HYPEN_E_DOT in requirements:
        requirements.remove(HYPEN_E_DOT)
        
    return requirements

setup(
    name='kn_mlproject',
    version='0.1',
    author='Vikas Sharma',
    author_email="macvjuhu@yahoo.com",
    packages=find_packages(),
    install_requires=get_requirements('requirements.txt'),
)
