class DockerEnvironment
  def map(source_dir, target_dir)
    @volumes ||= []
    @volumes << "-v #{source_dir}:#{target_dir}:ro"
  end

  def exec(cmd:, args: [], working_dir: nil)
    `docker run #{@volumes.join(' ')} --name #{name} -d -it cloudfoundry/lucid64 bash`
    `docker exec #{name} #{cmd} #{args.join ' '}`
  end

  def python(file:, &block)
    exec(cmd: 'source', args: ['/build/**/*.sh'])
    output = exec(
      cmd: '/build/.heroku/python/bin/python',
      args: [file]
    )
    block.call(output)
  end

  def cleanup!
    `docker rm -f #{name}`
  end

  private

  def name
    @name ||= "docker-env-#{Time.now.to_i}"
  end
end


# class PythonEnvironment
  # def app
    # @app ||= Machete.deploy_app('flask_web_app')
  # end

  # def execute(file: nil, code: nil, &block)
    # if file
      # file_path = File.join(Dir.pwd, 'cf_spec', 'fixtures', 'features', file)
      # code = File.read(file_path)
    # end

    # code.gsub!(/^#{code.scan(/^\s*/).min_by{|l|l.length}}/, "")

    # app_url = Machete::CF::CLI.url_for_app(app)
    # response = HTTParty.post("http://#{app_url}/execute", body: {code: code})
    # yield(response.body)
  # end
# end

require 'shellwords'

class PythonEnvironment
  def initialize
    raise "dockery-build missing" unless File.exist?(dockery_build_dir)
  end

  def execute(file: nil, &block)
    command = [
      "#{dockery_build_dir}/bin/deploy",
      '-b', buildpack_dir,
      '-a', app_dir,
      '-c', "python #{file}"
    ].shelljoin

    puts "Running command: #{command}"

    output = `#{command}`
    yield(output)
  end

  private

  def dockery_build_dir
    File.expand_path('~/workspace/dockery-build')
  end

  def buildpack_dir
    File.expand_path('~/workspace/python-buildpack')
  end

  def app_dir
    File.join(buildpack_dir, 'cf_spec', 'fixtures', 'features')
  end
end
