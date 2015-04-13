require 'spec_helper'
require 'support/python_environment'


describe 'dependencies in the manifest' do
  before do
    @env = DockerEnvironment.new
    @env.map('~/workspace/python-buildpack', '/buildpack')
    @env.map('~/workspace/python-buildpack/cf_spec/fixtures/features', '/src')
    @env.exec(cmd: 'cp', args: ['-a', '/src/.', '/build'])
    @env.exec(cmd: 'mkdir', args: ['-p', '/app'])
    @env.exec(cmd: '/buildpack/bin/compile', args: ['/build', '/tmp'], working_dir: '/buildpack')
  end

  after { @env.cleanup! }

  describe '#libffi' do
    it 'can integrate with C-header files' do
      @env.python(file: '/build/libffi.py') do |output|
        expect(output).to eq "hi there, world!\n"
      end
    end
  end

  describe '#libmemcache' do
    it 'cannot connect with the memcache server' do
      @env.python(file: '/build/libmemcache.py') do |output|
        expect(output).to eq "Could not connect\n"
      end
    end
  end
end
