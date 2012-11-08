/*
 * This Work is in the public domain and is provided on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied,
 * including, without limitation, any warranties or conditions of TITLE,
 * NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A PARTICULAR PURPOSE.
 * You are solely responsible for determining the appropriateness of using
 * this Work and assume any risks associated with your use of this Work.
 *
 * This Work includes contributions authored by David E. Jones, not as a
 * "work for hire", who hereby disclaims any copyright to the same.
 */
package org.moqui.context;

/** For trace, error, etc logging to the console, files, etc. */
public interface LoggerFacade {
    /** Log level copied from org.org.apache.log4j.Level to avoid requiring that on the classpath. */
    public static final int	TRACE_INT = 5000;
    public static final int	ALL_INT = -2147483648;
    public static final int	DEBUG_INT = 10000;
    public static final int	ERROR_INT = 40000;
    public static final int	FATAL_INT = 50000;
    public static final int	INFO_INT = 20000;
    public static final int	OFF_INT = 2147483647;
    public static final int	WARN_INT = 30000;

    /** Log a message and/or Throwable error at the given level.
     *
     * This is meant to be used for scripts, xml-actions, etc.
     *
     * In Java or Groovy classes it is better to use SLF4J directly, with something like:
     * <code>
     * public class Wombat {
     *   final static org.slf4j.Logger logger = org.slf4j.LoggerFactory.getLogger(Wombat.class);
     *
     *   public void setTemperature(Integer temperature) {
     *     Integer oldT = t;
     *     Integer t = temperature;
     *     logger.debug("Temperature set to {}. Old temperature was {}.", t, oldT);
     *     if(temperature.intValue() > 50) {
     *       logger.info("Temperature has risen above 50 degrees.");
     *     }
     *   }
     * }
     * </code>
     *
     * @param level The logging level. Options should come from org.apache.log4j.Level.  
     * @param message The message text to log. If contains ${} syntax will be expanded from the current context.
     * @param thrown
     */
    void log(int level, String message, Throwable thrown);

    void trace(String message);
    void debug(String message);
    void info(String message);
    void warn(String message);
    void error(String message);

    /** Is the given logging level enabled? */
    boolean logEnabled(int level);
}
