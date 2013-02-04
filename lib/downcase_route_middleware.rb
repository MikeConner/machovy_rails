class DowncaseRouteMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    if env['PATH_INFO'] =~ /redeem$/i
      env['PATH_INFO'] = env['PATH_INFO'].downcase
    end

    @app.call(env)
  end
end

